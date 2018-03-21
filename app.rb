# frozen_string_literal: true

require 'sinatra'
require 'sinatra/respond_with'
require_relative 'init'

configure do
  log_file = File.new(APP_ROOT.join('log', "#{settings.environment}.log"), 'a+')
  log_file.sync = true

  enable :static, :sessions, :dump_errors, :raise_errors
  set :protection, except: :frame_options
  set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(32) }

  use Rack::CommonLogger, Logger.new(log_file, 'weekly')
  use Rack::PostBodyContentTypeParser
  use Rack::Csrf, raise: true, check_only: ['POST:/lti/gdrive-list', 'POST:/lti/document'] unless test?

  set :assets_css_compressor, :sass
  set :assets_js_compressor, :uglifier
  set :assets_paths, %w(assets assets/js assets/css)
  register Sinatra::AssetPipeline
end

helpers AppHelpers

# ============
# Config

get '/' do
  'Canvas-GoogleDrive-Connector'
end

#
# The LTI app configuration inside canvas is done via an XML document using the
# IMS Common Cartridge specification https://www.imsglobal.org/cc/index.html.
#
get '/config.xml', provides: [:xml] do
  respond_with :lti_config do |fmt|
    fmt.xml { erb :'lti_config.xml', layout: false }
  end
end

# ============
# Credentials management

get '/credentials/new' do
  erb :'credentials/new'
end

post '/credentials' do
  credential = AuthCredential.generate
  erb :'credentials/created', locals: { credential: credential }
end

# ============
# Google Oauth2

get '/google-auth' do
  # Redirect to Google's authorization page if we don't have the credentials yet.
  # Check lib/GoogleAuth for more info
  redirect google_auth.authorization_url unless google_auth.credentials
end

get '/google-auth/callback' do
  google_auth.callback(request)
  erb :'google_auth/success'
end

# ============
# LTI endpoints

#
# Renders a google drive list.
#
# This action is used on XHR requests, after we've accessed a LTI launch url.
# Besides the lti session user and the google oauth2 we also check for CSRF token.
#
# Params:
#    * `folder_id` : list the contents of this folder
#    * `search_term` : term to search on the user's drive file names
#    * `action` : which kind of action should be enabled when a file is selected
#
post '/lti/gdrive-list' do
  authenticate! %i(user google)
  gdrive = GDriveService.new(google_auth.credentials)
  list = search_term ? gdrive.search(search_term) : gdrive.list(params[:folder_id])
  partial :'lti/gdrive_list', list: list, action: params[:action], search_term: search_term
end

#
# Launch url for course navigation (tab shown on the course sidebar)
# The *navigate* action just open the gdrive file  in a new browser tab.
#
# Params: LTI Launch (http://www.imsglobal.org/specs/ltiv1p0/implementation-guide) from Canvas
#
post '/lti/course-navigation' do
  authenticate! %i(lti google)
  erb :'lti/file_browser', locals: { action: :navigate }
end

#
# Launch url for editor selection (button inside the rich-text editor fields)
# The *select* action shows the options for `link` or `embed` the file in the content.
#
# Params: LTI Launch (http://www.imsglobal.org/specs/ltiv1p0/implementation-guide) from Canvas
#
post '/lti/editor-selection' do
  authenticate! %i(lti google)
  erb :'lti/file_browser', locals: { action: :select }
end

#
# Launch url for resource selection (module -> add item -> external tool)
# The *link_resource* action generate a lti-link for the resource selected.
#
# Params: LTI Launch (http://www.imsglobal.org/specs/ltiv1p0/implementation-guide) from Canvas
#
post '/lti/resource-selection' do
  authenticate! %i(lti google)
  erb :'lti/file_browser', locals: { action: :link_resource }
end

#
# Launch url for resource selection (module -> add item -> external tool)
# The *link_resource* action generate a lti-link for the resource selected.
#
# Params: LTI Launch (http://www.imsglobal.org/specs/ltiv1p0/implementation-guide) from Canvas
#
post '/lti/link-selection' do
  authenticate! %i(lti google)
  erb :'lti/file_browser', locals: { action: :link_resource }
end

#
# Simple proxy for a drive document called from a LtiLinkItem.
#
# Params:
#   * file_id : the gdrive file id
#   * LTI Launch (http://www.imsglobal.org/specs/ltiv1p0/implementation-guide) from Canvas
#
post '/lti/resources/:file_id' do |file_id|
  authenticate! %i(lti)
  redirect "https://docs.google.com/document/d/#{file_id}"
end

#
# Launch url for homework submission (tab on the assignment submission form)
# The *submit* action generate a lti-link object (https://www.imsglobal.org/specs/lticiv1p0/specification-1).
# This object is later used to embed an html snapshot of the file on the speed-grader.
#
# Params: LTI Launch (http://www.imsglobal.org/specs/ltiv1p0/implementation-guide) from Canvas
#
post '/lti/homework-submission' do
  authenticate! %i(lti google)
  SubmissionContext.new(user_id, params).save
  erb :'lti/file_browser', locals: { action: :submit }
end

#
# Generate an HTML snapshot of the google drive document
#
# Params:
#   * file_id : the gdrive file id
#
post '/lti/documents' do
  authenticate! %i(user google)
  file = GDriveService.new(google_auth.credentials).fetch(params[:file_id])
  context = SubmissionContext.new(user_id, params).fetch
  Document.save_submission_from_gdrive(file, context)
  erb :'lti/content-submission', locals: { file: file }
end

#
# Renders the document snapshot HTML content for embeding on the speed-grader
# Usually called from a `LtiLinkItem` object on Canvas.
#
# Params:
#   * file_id : the gdrive file id
#   * LTI Launch (http://www.imsglobal.org/specs/ltiv1p0/implementation-guide) from Canvas
#
post '/lti/documents/:file_id' do |file_id|
  authenticate! %i(lti)
  Document.find_by!(file_id: file_id).content
end
