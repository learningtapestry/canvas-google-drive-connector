# frozen_string_literal: true

require 'ims'

class LtiAuth
  attr_reader :error

  def initialize(request)
    @url = request.url
    @params = request.params.except(:captures)
  end

  def valid?
    unless shared_secret
      @error = "No key/pair credentials for #{params['oauth_consumer_key']}"
      return false
    end

    authenticator = IMS::LTI::Services::MessageAuthenticator.new(url, params, shared_secret)
    unless authenticator.valid_signature?
      @error = 'Invalid Signature'
      return false
    end

    if expired?
      @error = "Timestamp expired #{params['oauth_timestamp']}"
      return false
    end

    true
  end

  private

  attr_reader :params, :url

  def expired?
    DateTime.strptime(params['oauth_timestamp'], '%s') < 5.minutes.ago # rubocop:disable Style/DateTime
  end

  def shared_secret
    @shared_secret ||= AuthCredential.find_by(key: params['oauth_consumer_key'])&.secret
  end
end
