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

  def self.build_file_item(f)
    url = (ENV['LTI_APP_DOMAIN'] + "/lti/documents/#{f.id}")
    {
      '@type': "LtiLinkItem",
      '@id': url,
      url: url,
      title: f.name,
      text: f.name,
      mediaType: 'application/vnd.ims.lti.v1.ltilink',
      windowTarget: '',
      placementAdvice: {
        displayWidth: 800,
        displayHeight: 600,
        presentationDocumentTarget: 'window'
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
