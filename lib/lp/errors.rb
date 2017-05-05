module LP::Errors 

  class BadParameters < RDF::LDP::BadRequest    
    def message()
      'The request URL must provide encoded URLs with the "url" parameter, such as
        "?uri[]=http%3A%2F%2Fviaf.org%2Fviaf%2F36915259&uri[]=http%3A%2F%2Fviaf.org%2Fviaf%2F27203135"
        or "?uri=http%3A%2F%2Fviaf.org%2Fviaf%2F36915259".'
    end
  end

  class InvalidUri < RDF::LDP::BadRequest    
    def initialize(uri=nil)
      msg = "One of the provided URIs is invalid#{(', '+ uri) if uri}."
      super(msg)
    end
  end


  class CouldNotFetch < RDF::LDP::NotFound    
    def initialize(uri=nil)
      msg = "The data could not fetch from the external endpoint#{(', '+ uri) if uri}."
      super(msg)
    end
  end

  class TooManyRedirects < RDF::LDP::NotFound   
    def message
      'Too many HTTP redirects.'
    end
  end

  class UnsupportedContentType < RDF::LDP::NotFound   
    def initialize(content_type=nil)
      msg = "The fetched data is associated with an unsupported content type#{(', '+ content_type) if content_type}."
      super(msg)
    end
  end

  class AlreadyExists < RDF::LDP::RequestError   
      def initialize(uri=nil)
        msg = "Existing resource#{(', identified with '+ uri+' ,') if uri} attempted to be initialized again."
        super(msg)
      end
  end

end