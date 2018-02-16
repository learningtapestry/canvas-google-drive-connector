# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv/load'
require 'pathname'

APP_ENV = ENV['RACK_ENV'] || 'development'
APP_ROOT = Pathname.new(File.expand_path __dir__)
Bundler.require(:default, APP_ENV)

require 'require_all'
require_all 'models'
require_all 'lib'
