# frozen_string_literal: true

class CreateAuthNonce < ActiveRecord::Migration[5.1]
  def change
    create_table :auth_nonces do |t|
      t.string :nonce, null: false, index: true
      t.bigint :timestamp, null: false
    end
  end
end
