module KBA::Aggregatable
  
  SOURCE_URI_ROOTS = [ 'http://www.wikidata.org/', 
                       'https://www.wikidata.org/',
                       'http://viaf.org/',
                       'https://viaf.org/', ].freeze

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods

    def aggregatable?
      true
    end

  end

  def aggregatable?
    true
  end

  def aggregated?
    @aggregated ||= false
  end

  # TODO: Dereference each URI in source_uris, 
  # and extract the relevant data.
  # Handle AlreadyExists errors when dereferencing.
  def aggregate

    source_uris.each do |uri|
      resource = KBA::Resource.new(uri, @data)
      
      begin
        resource.dereference
      rescue KBA::Errors::AlreadyExists => e
        p e.message
      end

      resource.graph.query([uri, RDF.type, :o]).each do |statement| 
        graph << RDF::Statement(
          subject_uri, 
          RDF.type, 
          statement.object, 
          graph_name: subject_uri)
      end

    end 

    @aggregated = true
  end

  def source_uris
    @source_uris ||= same_as_uris.select do |uri| 
      SOURCE_URI_ROOTS.include? uri.root.to_s
    end
  end



end