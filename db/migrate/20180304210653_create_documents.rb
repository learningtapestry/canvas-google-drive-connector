# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.string :file_id, null: false, unique: true, index: true
      t.string :content_type
      t.text :content
      t.string :user_id
      t.string :doc_type
      t.jsonb :context, defaut: {}, null: false

      t.timestamps null: false
    end
  end
end
