# frozen_string_literal: true

require 'rack'
require 'rack/contrib'
require 'sinatra'
require 'sinatra/respond_with'
require 'sinatra/namespace'
require_relative 'init'

configure :development do
  enable :logging, :dump_errors, :raise_errors
end

# Add json data to params on POST requests
use Rack::PostBodyContentTypeParser

# allow embeding on iFrames
set :protection, except: :frame_options

helpers do
  def authorized?
    true
    # if env['HTTP_AUTHORIZATION'].present?
    #   auth_token = env['HTTP_AUTHORIZATION'].match(/Token token="(\w+)"/)[1]
    #   return true if auth_token && AccessToken.where(token: auth_token).exists?
    # end
    # false
  end
end

get '/' do
end

get '/config.xml', provides: [:xml] do
  respond_with :lti_config
end

get '/credentials/new' do
  erb :'credentials/new'
end

namespace :lti do
  before do
    error 401 unless authorized?
  end

  post 'course-navigation' do
    erb :'lti/course_navigation'
  end
end
