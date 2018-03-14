# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'rspec'
require 'database_cleaner'
require 'simplecov'

SimpleCov.start

require_relative '../app'

DatabaseCleaner.strategy = :transaction

module RSpecMixin
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def lti_request(path, credential: nil, timestamp: nil, signature: nil)
    credential ||= AuthCredential.generate
    url = 'http://example.org' + path
    params = {
      oauth_consumer_key: credential.key,
      oauth_signature_method: 'HMAC-SHA1',
      oauth_timestamp: timestamp || Time.current.to_i.to_s,
      oauth_nonce: 'XxmJ35LrLDc4vFR1JHHFroTC2ty02DWUZP98mKQ',
      oauth_version: '1.0',
      context_id: '4dde05e8ca1973bcca9bffc13e1548820eee93a3',
      context_label: 'GDrive',
      context_title: 'GDrive test',
      custom_user_id: 'user-id',
      launch_presentation_document_target: 'iframe',
      launch_presentation_locale: 'en',
      lti_message_type: 'ContentItemSelectionRequest',
      lti_version: 'LTI-1p0',
      roles: 'Instructor,urn:lti:instrole:ims/lis/Administrator',
      tool_consumer_instance_guid: '794d72b707af6ea82cfe3d5d473f16888a8366c7.canvas.docker',
      user_id: '535fa085f22b4655f48cd5a36a9215f64c062838'
    }
    unless signature
      authenticator = IMS::LTI::Services::MessageAuthenticator.new(url, params, credential.secret)
      signature = authenticator.simple_oauth_header.send(:signature)
    end
    post path, params.merge(oauth_signature: signature)
  end

  def session
    last_request.env['rack.session']
  end
end

RSpec::Matchers.define :have_css do |selector|
  match do |resp|
    Nokogiri::HTML(resp.body).css(selector).first
  end
  failure_message do |_resp|
    "expected the page to have css '#{selector}'"
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
