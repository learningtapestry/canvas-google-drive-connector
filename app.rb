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

use Rack::PostBodyContentTypeParser # Add json data to params on POST requests
set :protection, except: :frame_options # allow embeding on iFrames
set :static, true

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
    error 401 unless LtiAuth.authenticate?(request)
  end

  post '/course-navigation' do
    erb :'lti/course_navigation'
  end
end
