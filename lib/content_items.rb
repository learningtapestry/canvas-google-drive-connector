module ContentItems
  def self.build_link(f)
    {
      "@context" => 'http://purl.imsglobal.org/ctx/lti/v1/ContentItem',
      "@graph" => [
        {
          "@type": "ContentItem",
          "@id": f.id,
          "url": f.link,
          "title": f.name,
          "text": f.name,
          "mediaType": "text/html",
        }
      ]
    }
  end

  def self.build_embed(f)
    {
      "@context" => 'http://purl.imsglobal.org/ctx/lti/v1/ContentItem',
      "@graph" => [
      ]
    }
  end
end
