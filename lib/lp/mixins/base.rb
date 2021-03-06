module LP
  module Base

    ##
    # @return [Array<RDF::URI>] An array of URIs that
    # are specified to identify the resource.
    # 
    def same_as_uris 
      @same_as_uris ||= graph.query(
        [subject_uri, RDF::Vocab::SCHEMA.sameAs, :o]
      ).map do |statement| 
        statement.object 
      end
    end

    ##
    # Setting the URIs that are identified to be `sameAs` self.
    # 
    # @param [Array<RDF::URI>] uris - An array of URIs
    # identifying self.
    def same_as_uris=(uris)

      uris.each do |uri|
        
        # It is not a problem if the statement already exists,
        # since it is being inserted into a hash.  
        graph << RDF::Statement(
          subject_uri, 
          RDF::Vocab::SCHEMA.sameAs, 
          uri, 
          graph_name: subject_uri)
      
      end
    end
    
  end
end