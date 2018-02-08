# frozen_string_literal: true

require 'securerandom'

class AuthNonce < ActiveRecord::Base
  validates :nonce, :timestamp, presence: true
end
