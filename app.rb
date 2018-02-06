# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require_relative 'init'

configure :development do
  enable :logging, :dump_errors, :raise_errors
end

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

before do
  error 401 unless authorized?
end

get '/' do
  json Hash[lti_canvas_google: true]
end
