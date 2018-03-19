# frozen_string_literal: true

class Document < ActiveRecord::Base
  validates :file_id, presence: true, uniqueness: true

  def self.save_submission_from_gdrive(file, ctx)
    ctx ||= {}
    find_or_initialize_by(file_id: file.id).tap do |doc|
      doc.assign_attributes(
        content: file.content,
        content_type: 'text/html',
        context: ctx,
        doc_type: ctx['submission'],
        user_id: ctx['custom_user_id']
      )
      doc.save!
    end
  end
end
