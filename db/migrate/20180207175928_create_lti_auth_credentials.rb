# frozen_string_literal: true

class CreateLtiAuthCredentials < ActiveRecord::Migration[5.1]
  def change
    create_table :lti_auth_credentials do |t|
      t.string :key, null: false, index: true
      t.string :secret, null: false

      t.timestamps null: false
    end
  end
end
