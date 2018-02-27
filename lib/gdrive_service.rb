# frozen_string_literal: true

require 'google/apis/drive_v3'

class GDriveService
  MIME_FOLDER = 'application/vnd.google-apps.folder'
  MIME_FILE = 'application/vnd.google-apps.document'

  # rubocop:disable Style/SingleLineMethods
  GDriveFile = Struct.new(:id, :name, :kind, :link, :icon, keyword_init: true) do
    def file?; kind == :file end

    def folder?; kind == :folder end
  end
  # rubocop:enable Style/SingleLineMethods

  def initialize(credentials)
    @credentials = credentials
  end

  def list(folder = 'root')
    gdrive_files = service.fetch_all(items: :files) do |token|
      service.list_files(
        q: "'#{folder}' in parents and trashed = false",
        order_by: 'folder, name',
        fields: 'files(id, name, mimeType, webViewLink, iconLink)',
        page_token: token
      )
    end
    gdrive_files.map do |f|
      kind = f.mime_type == MIME_FOLDER ? :folder : :file
      GDriveFile.new(id: f.id, name: f.name, kind: kind, link: f.web_view_link, icon: f.icon_link)
    end
  end

  private

  def service
    @servie ||= begin
      service = Google::Apis::DriveV3::DriveService.new
      service.authorization = @credentials
      service
    end
  end
end
