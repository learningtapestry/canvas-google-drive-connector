# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv/load'

APP_ENV = ENV['RACK_ENV'] || 'development'
APP_ROOT = File.expand_path __dir__

require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader' if development?

require 'byebug' if development? || test?
require 'require_all'

def test?
  APP_ENV == 'test'
end

require_all 'models'
require_all 'lib'
