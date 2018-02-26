# frozen_string_literal: true

require_relative 'spec_helper'

describe 'root' do
  before { get '/' }

  it { expect(last_response).to be_ok }
end

describe 'config' do
  before { get '/config.xml' }

  it { expect(last_response).to be_ok }
  it { expect(last_response.content_type).to match(%r{application/xml}) }
  it { expect(last_response).to match(/<blti:launch_url>/) }
end

describe 'credentials' do
  it 'renders a generate credentials buttons' do
    get '/credentials/new'
    expect(last_response).to match(/class="credentials-generate-btn"/)
  end

  it 'generates new credentials' do
    creds_count = AuthCredential.count
    post '/credentials'
    expect(AuthCredential.count).to eq(creds_count + 1)
    expect(last_response).to match(%r{<div class="credential-value">#{AuthCredential.last.key}</div>})
  end
end
