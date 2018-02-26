# frozen_string_literal: true

require_relative 'test_helper'

def app
  Sinatra::Application
end

describe 'root' do
  before { get '/' }

  it { assert last_response.ok? }
end

describe 'config' do
  before { get '/config.xml' }

  it { assert last_response.ok? }
  it { assert last_response.content_type.match(%r{application/xml}) }
  it { assert last_response.match(/<blti:launch_url>/) }
end

describe 'credentials' do
  it 'renders a generate credentials buttons' do
    get '/credentials/new'
    assert last_response.match(/class="credentials-generate-btn"/)
  end

  it 'generates new credentials' do
    creds_count = AuthCredential.count
    post '/credentials'
    assert_equal AuthCredential.count, creds_count + 1
    assert last_response.match(%r{<div class="credential-value">#{AuthCredential.last.key}</div>})
  end
end
