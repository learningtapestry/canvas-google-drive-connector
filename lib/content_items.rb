# frozen_string_literal: true

#
# Build LTI content items objects to be returned on ContentItemSelectionResponse
# For more info on this spec check the link below:
# https://www.imsglobal.org/lti/model/mediatype/application/vnd/ims/lti/v1/contentitems%2Bjson/index.html
#
module ContentItems
  #
  # Dispatcher for type specific builder methods.
  # Params:
  #   - f: GDriveFile instance for the file selected
  #   - type: type of content_item (e.g: embed, file, link)
  #
  def self.build(f, type)
    item = send(:"build_#{type}_item", f)
    { '@context': 'http://purl.imsglobal.org/ctx/lti/v1/ContentItem', '@graph': [item] }
  end

  #
  # Embed a simple html piece into an iframe
  #
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

  #
  # Build a LtiLinkItem launch object for a embeded document HTML snapshot.
  # The LtiLinkItem is essentialy a way for canvas to display resources dinamicaly fetching from our api.
  # https://www.imsglobal.org/lti/model/mediatype/application/vnd/ims/lti/v1/contentitems%2Bjson/index.html#LtiLinkItem
  #
  def self.build_file_item(f)
    url = AppHelpers.url_for "/lti/documents/#{f.id}", full: true
    {
      '@type': 'LtiLinkItem',
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

  #
  # Build a simple HTML link (anchor).
  # Keep in mind that `link` here is very different than a `LtiLinkItem` (check `build_file_item` for more info).
  #
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

  #
  # Build a LtiLinkItem launch object for a embeded resource.
  # https://www.imsglobal.org/lti/model/mediatype/application/vnd/ims/lti/v1/contentitems%2Bjson/index.html#LtiLinkItem
  #
  def self.build_resource_item(f)
    url = AppHelpers.url_for "/lti/resources/#{f.id}", full: true
    {
      '@type': 'LtiLinkItem',
      '@id': url,
      url: url,
      title: f.name,
      text: f.name,
      mediaType: 'application/vnd.ims.lti.v1.ltilink',
      placementAdvice: {
        displayWidth: 800,
        displayHeight: 600,
        presentationDocumentTarget: 'iframe'
      }
    }
  end
end
