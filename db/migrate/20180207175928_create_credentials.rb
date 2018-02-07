# frozen_string_literal: true

class CreateCredentials < ActiveRecord::Migration[5.1]
  def change
    create_table :credentials do |t|
      t.string :key, null: false, index: true
      t.string :secret, null: false, index: true

      t.timestamps
    end
  end
end
