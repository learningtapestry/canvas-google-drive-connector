# frozen_string_literal: true

require 'logger'
require 'rack'
require 'rack/contrib'
require 'sinatra'
require 'sinatra/respond_with'
require 'sinatra/namespace'

require_relative 'init'

configure do
  enable :dump_errors, :raise_errors if development?
  enable :static, :sessions
  set :protection, except: :frame_options # allow embeding on iFrames

  log_file = File.new(APP_ROOT.join('logs', "#{settings.environment}.log"), 'a+')
  log_file.sync = true

  use Rack::CommonLogger, Logger.new(log_file, 'weekly')
  use Rack::PostBodyContentTypeParser # Add json data to params on POST requests
end

helpers do
  def partial(template, locals = {})
    erb(template, layout: false, locals: locals)
  end

  def google_auth
    @google_auth ||= GoogleAuth.new(request, session[:user_id])
  end
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
  erb :'credentials/created', locals: { credential: Credential.generate }
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
    if (lti_auth = LtiAuth.new(request)) && lti_auth.valid?
      session[:user_id] = params['custom_user_id']
    else
      logger.warn("LTI Authentication error: #{lti_auth.error}")
      error 401
    end
    # session[:user_id] = 1
    halt erb(:'google_auth/authorize') unless session[:user_id] && google_auth.credentials
  end

  post '/course-navigation' do
    gdrive = GDriveService.new(google_auth.credentials)
    erb :'lti/course_navigation', locals: { gdrive: gdrive }
  end
end
