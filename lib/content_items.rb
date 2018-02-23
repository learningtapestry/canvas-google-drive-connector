# frozen_string_literal: true

module ContentItems
  def self.build(f, type)
    item = {
      '@type': 'ContentItem',
      '@id': f.id,
      url: f.link,
      title: f.name,
      mediaType: 'text/html',
    }
    if type == :embed
      item[:placementAdvice] = {
        presentationDocumentTarget: 'iframe',
        displayWidth: '100%',
        displayHeight: '600'
      }
    else # :link
      item[:text] = f.name
    end
    { '@context': 'http://purl.imsglobal.org/ctx/lti/v1/ContentItem', '@graph': [item] }
  end
end
