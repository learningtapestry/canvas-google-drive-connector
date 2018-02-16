# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'database_cleaner'
require_relative '../app'

DatabaseCleaner.strategy = :transaction

module Minitest
  class Spec
    include Rack::Test::Methods

    before(:each) { DatabaseCleaner.start }
    after(:each) { DatabaseCleaner.clean }
  end
end
