module LP::Aggregatable
  include LP::QueryMaker

  SOURCE_URI_ROOTS = [ 
    'http://www.wikidata.org/', 
    'https://www.wikidata.org/',
    'http://viaf.org/',
    'https://viaf.org/', 
  ].freeze

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

  def aggregate

    source_uris.each do |uri|
      # Temporarily using a single RDF::Repository 
      # as an in-memory cache.
      resource = LP::Resource.new(uri, @data)
      # resource = LP::Resource.new(uri, RDF::Repository.new)
      
      begin
        resource.fetch_from_db_or_dereference!
      rescue LP::Errors::AlreadyExists => e
        p e.message
      end

      resource.graph.query([uri, RDF.type, :o]).each do |statement| 
        graph << RDF::Statement(
          subject_uri, 
          RDF.type, 
          statement.object, 
          graph_name: subject_uri)
      end

      extract_from_resource(resource)

    end 

    @aggregated = true
  end

  def source_uris
    @source_uris ||= same_as_uris.select do |uri| 
      SOURCE_URI_ROOTS.include? uri.root.to_s
    end
  end

  def extract_from_resource(resource)
    query = make_sparql_query(resource.subject_uri)
    statements = SPARQL.execute(query, resource.graph)
    statements.each do |statement|
 
      statement.graph_name = subject_uri
      graph << statement
 
    end

  end

end
