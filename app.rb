# frozen_string_literal: true

require 'sinatra'
require 'sinatra/respond_with'
require_relative 'init'

configure do
  log_file = File.new(APP_ROOT.join('log', "#{settings.environment}.log"), 'a+')
  log_file.sync = true

  set :protection, except: :frame_options
  enable :dump_errors, :raise_errors if development?
  enable :static, :sessions

  use Rack::CommonLogger, Logger.new(log_file, 'weekly')
  use Rack::PostBodyContentTypeParser
  use Rack::Csrf, raise: true, check_only: ['POST:/lti/gdrive-list', 'POST:/lti/content'] unless test?

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
  session[:user_id] && authenticate!([:google]) # && CSRF
  gdrive = GDriveService.new(google_auth.credentials)
  partial :'lti/gdrive_list', list: gdrive.list(params[:folder_id])
end

post '/lti/course-navigation' do
  authenticate! %i(lti google)
  erb :'lti/file_browser', locals: { browser_type: :navigation }
end

post '/lti/editor-selection' do
  authenticate! %i(lti google)
  erb :'lti/file_browser', locals: { browser_type: :selection }
end

post '/lti/homework-submission' do
  authenticate! %i(lti google)
  erb :'lti/file_browser', locals: { browser_type: :submission }
end

post '/lti/content' do
  session[:user_id] && authenticate!([:google]) # && CSRF
  file = GDriveService.new(google_auth.credentials).fetch(params[:file_id])
  File.open(APP_ROOT.join('tmp', "#{file.id}.html"), 'w') { |f| f.write(file.content) }
  erb :'lti/content-submission', locals: { file: file }
end

get '/lti/content/:file_id' do |file_id|
  filename = "#{file_id}.html"
  headers['Content-Disposition'] = "attachment;filename=\"#{filename}\""
  content_type 'application/octet-stream'
  File.read("./tmp/#{filename}")
end
