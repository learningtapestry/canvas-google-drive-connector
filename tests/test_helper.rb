# frozen_string_literal: true
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'database_cleaner'

require_relative '../app'

DatabaseCleaner.strategy = :transaction

class Minitest::Spec
  before :each do
    DatabaseCleaner.start
  end

  after :each do
    byebug
    DatabaseCleaner.clean
  end
end
