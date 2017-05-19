##
# Mixin for fetching resources identified with URIs. 
#
module LP::Fetcher

  CONTENT_TYPES = ['text/turtle', 'application/ld+json'].freeze

  ##
  # Fetches a resource identified with the given URI,
  #
  # @param [String] uri_str - The URI to be fetched as a String.
  # @param [Integer] limit - The maximum number of redirections allowed.
  # @see http://ruby-doc.org/stdlib-2.4.0/libdoc/net/http/rdoc/Net/HTTP.html
  # @raise LP::TooManyRedirects - When the redirect limit is exceeded. 
  # @raise LP::CouldNotFetch - When the resource cannot be fetched. 
  def fetch(uri_str, limit = 10)
  
    raise LP::TooManyRedirects if limit == 0

    request = Net::HTTP::Get.new(uri_str)
    request['Accept'] = CONTENT_TYPES.join(', ')

    use_ssl = /^https:\/\//.match?(uri_str)
    uri = URI(uri_str)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: use_ssl) do |http|
      http.request(request)
    end

    case response
    when Net::HTTPSuccess then
      
      if ! CONTENT_TYPES.include?(response.content_type)
        raise LP::Errors::UnsupportedContentType, response.content_type
      end
      response

    when Net::HTTPRedirection then
      location = response['location']      
      raise LP::CouldNotFetch, uri_str if !location
      
      location_uri = RDF::URI(location)

      if location_uri.relative?
        location_uri = RDF::URI(uri).join(location_uri)
      end

      warn "redirected to #{location}"
      fetch(location_uri.to_s, limit - 1)

    else
      raise LP::CouldNotFetch, uri_str
    end
  end

end
