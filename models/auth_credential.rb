# frozen_string_literal: true

require 'securerandom'

class AuthCredential < ActiveRecord::Base
  validates :key, :secret, presence: true

  def self.generate
    create!(key: SecureRandom.uuid, secret: SecureRandom.hex(16))
  end
end
