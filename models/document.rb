# frozen_string_literal: true

class Document < ActiveRecord::Base
  validates :file_id, presence: true, uniqueness: true

  def self.persist_gdrive_file(file, ctx)
    ctx ||= {}
    find_or_initialize_by(file_id: file.id).tap do |doc|
      doc.assign_attributes(content_type: 'text/html', content: file.content, context: ctx,
                            doc_type: ctx['submission'], user_id: ctx['custom_user_id'])
      doc.save!
    end
  end
end
