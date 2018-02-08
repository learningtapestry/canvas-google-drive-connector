# frozen_string_literal: true

require 'ims'

class LtiAuth
  def initialize(req)
    @url = req.url
    @params = req.params
  end

  def valid?
    return false unless shared_secret

    authenticator = IMS::LTI::Services::MessageAuthenticator.new(url, params, shared_secret)
    return false unless authenticator.valid_signature?

    return false if nonce_used?
    use_nonce!

    return false if expired?

    true
  end

  private

  attr_reader :params, :url

  def expired?
    DateTime.strptime(params['oauth_timestamp'],'%s') < 5.minutes.ago
  end

  def nonce_used?
    LtiAuthNonce.exists?(nonce: params['oauth_nonce'])
  end

  def shared_secret
    LtiAuthCredential.find_by(key: params['oauth_consumer_key'])&.secret
  end

  def use_nonce!
    LtiAuthNonce.create!(nonce: params['oauth_nonce'], timestamp: params['oauth_timestamp'])
  end
end
