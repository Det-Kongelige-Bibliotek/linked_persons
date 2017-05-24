module LP

  ##
  # Rack middleware to remove unsupported Accept headers
  # from the incoming request. This is needed as 
  # Rack::LinkedData::ContentNegotiation does not 
  # ignore types that it does not support, but throws an
  # invalid statement error, like so:
  # 
  # ERROR Statement #<RDF::Statement:0x27c9348(
  #   <?uri=http%3A%2F%2Fviaf.org%2Fviaf%2F36915259> 
  #   <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> 
  #   <http://wikiba.se/ontology-beta#Item> 
  # .)> is invalid
  #
  class RequestHeadersHandler
    
    SUPPORTED_CONTENT_TYPES = [
      "application/ld+json",
      "text/turtle",
      "text/*",
      "*/*",
    ].freeze

    SUPPORTED_CONTENT_TYPES = ["application/ld+json","application/*","text/turtle","text/*","*/*",]

    def initialize(app)
      @app = app
    end
    
    def call(env)
      accept_headers = env['HTTP_ACCEPT'].split(',').map(&:strip)
      
      env['HTTP_ACCEPT'] = accept_headers.select do |header| 
        SUPPORTED_CONTENT_TYPES.include?(header)
      end.join(',')

      @app.call(env)
    end

  end

end
