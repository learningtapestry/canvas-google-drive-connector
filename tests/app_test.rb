# frozen_string_literal: true
require_relative 'test_helper'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe :app do
  it 'have a valid root endpoint' do
    get '/'
    assert last_response.ok?
  end
end
