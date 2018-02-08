# frozen_string_literal: true

require 'securerandom'

class LtiAuthNonce < ActiveRecord::Base
  validates :nonce, :timestamp, presence: true
end
