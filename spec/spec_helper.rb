# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'rspec'
require 'database_cleaner'
require_relative '../app'

DatabaseCleaner.strategy = :transaction

module RSpecMixin
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

RSpec.configure do |config|
  config.include RSpecMixin

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
