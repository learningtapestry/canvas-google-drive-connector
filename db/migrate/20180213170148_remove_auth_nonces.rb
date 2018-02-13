# frozen_string_literal: true

class RemoveAuthNonces < ActiveRecord::Migration[5.1]
  def change
    drop_table :auth_nonces
  end
end
