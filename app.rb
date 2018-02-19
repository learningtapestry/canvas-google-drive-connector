# frozen_string_literal: true

require 'sinatra'
require 'sinatra/respond_with'
require_relative 'init'

configure do
  log_file = File.new(APP_ROOT.join('logs', "#{settings.environment}.log"), 'a+')
  log_file.sync = true

  set :protection, except: :frame_options # allow embeding on iFrames
  enable :dump_errors, :raise_errors if development?
  enable :static, :sessions

  use Rack::CommonLogger, Logger.new(log_file, 'weekly')
  use Rack::PostBodyContentTypeParser # Add json data to params on POST requests
  use Rack::Csrf, raise: true, check_only: ['POST:/lti/gdrive-list']

  set :assets_css_compressor, :sass
  set :assets_js_compressor, :uglifier
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

get '/google_auth' do
  redirect google_auth.authorization_url unless google_auth.credentials
end

get '/google_auth/callback' do
  google_auth.callback(request)
  erb :'google_auth/success'
end

# ============
# LTI endpoints

# XXX: Temporary for local testing
get '/lti/course-navigation' do
  (session[:user_id] = 1) && authenticate!([:google])
  erb :'lti/course_navigation'
end

post '/lti/gdrive-list' do
  session[:user_id] && authenticate!([:google]) # && CSRF
  gdrive = GDriveService.new(google_auth.credentials)
  partial :'lti/gdrive_list', list: gdrive.list(params[:folder_id])
end

post '/lti/course-navigation' do
  authenticate! %i(lti google)
  erb :'lti/course_navigation'
end
