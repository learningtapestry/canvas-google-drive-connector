# frozen_string_literal: true

require 'sinatra'
require 'sinatra/respond_with'
require_relative 'init'

configure do
  log_file = File.new(APP_ROOT.join('log', "#{settings.environment}.log"), 'a+')
  log_file.sync = true

  set :protection, except: :frame_options
  enable :static, :sessions, :dump_errors, :raise_errors
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
  erb :'credentials/created', locals: { credential: AuthCredential.generate }
end

# ============
# Google Oauth2

get '/google-auth' do
  redirect google_auth.authorization_url unless google_auth.credentials
end

get '/google-auth/callback' do
  google_auth.callback(request)
  erb :'google_auth/success'
end

# ============
# LTI endpoints

post '/lti/gdrive-list' do
  user_id && authenticate!([:google])
  gdrive = GDriveService.new(google_auth.credentials)
  list = search_term ? gdrive.search(search_term) : gdrive.list(params[:folder_id])
  partial :'lti/gdrive_list', list: list, action: params[:action], search_term: search_term
end

post '/lti/course-navigation' do
  authenticate! %i(lti google)
  erb :'lti/file_browser', locals: { action: :navigate }
end

post '/lti/editor-selection' do
  authenticate! %i(lti google)
  erb :'lti/file_browser', locals: { action: :select }
end

post '/lti/homework-submission' do
  authenticate! %i(lti google)
  SubmissionContext.new(user_id, params).store
  erb :'lti/file_browser', locals: { action: :submit }
end

post '/lti/documents' do
  user_id && authenticate!([:google])
  file = GDriveService.new(google_auth.credentials).fetch params[:file_id]
  context = SubmissionContext.new(user_id, params).fetch
  Document.persist_gdrive_file file, context
  erb :'lti/content-submission', locals: { file: file }
end

post '/lti/documents/:file_id' do |file_id|
  authenticate! %i(lti)
  Document.find_by!(file_id: file_id).content
end
