# frozen_string_literal: true

require 'google/apis/drive_v3'

class GoogleDriveService
  MIME_FOLDER = 'application/vnd.google-apps.folder'
  MIME_FILE = 'application/vnd.google-apps.document'

  def initialize(credentials)
    @credentials = credentials
  end

  def list(parent_id = 'root', ident = 0)
    puts "list for '#{parent_id}'"
    file_list = service.fetch_all(items: :files) do |token|
      service.list_files(
        q: "'#{parent_id}' in parents and trashed = false",
        order_by: 'folder',
        fields: 'files(id, name, mimeType, webViewLink)',
        page_token: token
      )
    end.map { |f| build_file(f, ident) }
  end

  private

  def build_file(f, ident)
    kind = f.mime_type == MIME_FOLDER ? :folder : :file
    OpenStruct.new(
      name: f.name,
      kind: kind,
      id: f.id,
      children: (list(f.id, ident + 1) if kind == :folder && ident < 2 ),
      link: f.web_view_link
    )
  end

  def service
    @servie ||= begin
      service = Google::Apis::DriveV3::DriveService.new
      service.authorization = @credentials
      service
    end
  end
end
