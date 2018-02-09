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

  set :static, true
  set :protection, except: :frame_options # allow embeding on iFrames

  log_file = File.new(APP_ROOT.join('logs', "#{settings.environment}.log"), 'a+')
  log_file.sync = true

  use Rack::CommonLogger, Logger.new(log_file, 'weekly')
  use Rack::PostBodyContentTypeParser # Add json data to params on POST requests
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

namespace '/lti' do
  before do
    unless (lti_auth = LtiAuth.new(request)) && lti_auth.valid?
      logger.warn("LTI Authentication error: #{lti_auth.error}")
      error 401
    end
  end

  post '/course-navigation' do
    erb :'lti/course_navigation'
  end
end
