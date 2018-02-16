# frozen_string_literal: true

require 'logger'
require 'rack'
require 'rack/contrib'
require 'sinatra'
require 'sinatra/respond_with'
require 'sinatra/namespace'
require 'sprockets'
require 'uglifier'
require 'sass'

require_relative 'init'
require_relative 'helpers'

configure do
  enable :dump_errors, :raise_errors if development?
  enable :static, :sessions
  set :protection, except: :frame_options # allow embeding on iFrames

  # initialize new sprockets environment
  sprockets = Sprockets::Environment.new
  sprockets.append_path 'assets/stylesheets'
  sprockets.append_path 'assets/javascripts'
  sprockets.js_compressor = :uglify
  sprockets.css_compressor = :scss

  set :environment, sprockets

  log_file = File.new(APP_ROOT.join('logs', "#{settings.environment}.log"), 'a+')
  log_file.sync = true

  use Rack::CommonLogger, Logger.new(log_file, 'weekly')
  use Rack::PostBodyContentTypeParser # Add json data to params on POST requests
end

helpers Helpers

# get assets
get '/assets/*' do
  env['PATH_INFO'].sub!('/assets', '')
  settings.environment.call(env)
end

get '/' do
end

get '/config.xml', provides: [:xml] do
  respond_with :lti_config do |fmt|
    fmt.xml { erb :'lti_config.xml', layout: false }
  end
end

get '/credentials/new' do
  erb :'credentials/new'
end

post '/credentials' do
  erb :'credentials/created', locals: { credential: AuthCredential.generate }
end

get '/google_auth' do
  redirect google_auth.authorization_url unless google_auth.credentials
end

get '/google_auth/callback' do
  google_auth.callback(request)
  erb :'google_auth/success'
end

namespace '/lti' do
  before do
    if request.path.match? %r{/gdrive_list}
      session[:user_id] = 1 # XXX: Temporary for local testing
    else
      authenticate_lti
    end
    authenticate_google
  end

  get '/course-navigation' do
    gdrive = GDriveService.new(google_auth.credentials)
    erb :'lti/course_navigation', locals: { gdrive: gdrive }
  end

  post '/course-navigation' do
    gdrive = GDriveService.new(google_auth.credentials)
    erb :'lti/course_navigation', locals: { gdrive: gdrive }
  end
end
