# frozen_string_literal: true

class CreateAuthCredentials < ActiveRecord::Migration[5.1]
  def change
    create_table :auth_credentials do |t|
      t.string :key, null: false, index: true
      t.string :secret, null: false

      t.timestamps null: false
    end
  end
end
