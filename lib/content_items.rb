# frozen_string_literal: true

module ContentItems
  def self.build(f, type)
    item = send(:"build_#{type}_item", f)
    { '@context': 'http://purl.imsglobal.org/ctx/lti/v1/ContentItem', '@graph': [item] }
  end

  def self.build_embed_item(f)
    {
      '@type': 'ContentItem',
      '@id': f.id,
      url: f.link,
      title: f.name,
      mediaType: 'text/html',
      placementAdvice: {
        presentationDocumentTarget: 'iframe',
        displayWidth: '100%',
        displayHeight: '600'
      }
    }
  end

  def self.build_submit_item(f)
    {
      '@type': 'FileItem',
      '@id': f.id,
      url: (ENV['LTI_APP_DOMAIN'] + "/lti/content/#{f.id}"),
      text: f.name,
      # mediaType: 'text/html',
      placementAdvice: {
        presentationDocumentTarget: 'embed',
        displayWidth: '100%',
        displayHeight: '100%'
      }
    }

  end

  def self.build_link_item(f)
    {
      '@type': 'ContentItem',
      '@id': f.id,
      url: f.link,
      title: f.name,
      text: f.name,
      mediaType: 'text/html'
    }
  end
end
