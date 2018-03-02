# frozen_string_literal: true

require 'google/apis/drive_v3'

class GDriveService
  MIME_FOLDER = 'application/vnd.google-apps.folder'
  MIME_FILE = 'application/vnd.google-apps.document'

  # rubocop:disable Style/SingleLineMethods
  GDriveFile = Struct.new(:id, :name, :kind, :link, :icon, :content, keyword_init: true) do
    def file?; kind == :file end

    def folder?; kind == :folder end
  end
  # rubocop:enable Style/SingleLineMethods

  def initialize(credentials)
    @credentials = credentials
  end

  def list(folder = 'root')
    files = service.fetch_all(items: :files) do |token|
      service.list_files(
        q: "'#{folder}' in parents and trashed = false",
        order_by: 'folder, name',
        fields: 'files(id, name, mimeType, webViewLink, iconLink)',
        page_token: token
      )
    end
    files.map { |f| build_gdrive_file(f) }
  end

  def fetch(file_id)
    file = service.get_file(file_id, fields: 'id, name, mimeType, webViewLink, iconLink')
    content = service.export_file(file_id, 'text/html', download_dest: StringIO.new).string
    build_gdrive_file(file, content: content)
  end

  private

  def build_gdrive_file(f, content: nil)
    kind = f.mime_type == MIME_FOLDER ? :folder : :file
    GDriveFile.new(id: f.id, name: f.name, kind: kind, link: f.web_view_link, icon: f.icon_link, content: content)
  end

  def service
    @servie ||= begin
      service = Google::Apis::DriveV3::DriveService.new
      service.authorization = @credentials
      service
    end
  end
end
