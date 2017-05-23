class LP::Person < RDF::LDP::RDFSource
  include LP::Base
  include LP::Aggregatable
  include LP::Persistable

  TYPE_URI = RDF::Vocab::SCHEMA.Person.freeze

  ##
  # Fetches data for the resource identified
  # by the given URI and saves self if not saved. 
  # 
  # @param [String] uri_str - URI string identifying
  # the resource to be fetched. 
  # 
  # @return self
  def fetch_for_uri_str!(uri_str)
    fetch_for_uri_str(uri_str)
    save unless saved?
    self
  end

  ##
  # Fetches data for the resource identified
  # by the given URI. 
  # 
  # @param [String] uri_str - URI string identifying
  # the resource to be fetched. 
  # 
  # @return self
  def fetch_for_uri_str(uri_str)
    if saved?
      fetch_from_db
    else
      fetch_and_aggregate(uri_str)
    end

    self          
  end

  # @private
  def fetch_and_aggregate(uri_str)
    resource = LP::Resource.new(uri_str, @data)      
    resource.fetch_from_db_or_dereference!
    self.same_as_uris = resource.same_as_uris + [resource.subject_uri]
    graph << make_type_triple
    aggregate
  end

  # @private
  def make_type_triple
    RDF::Statement(subject_uri, RDF.type, TYPE_URI, 
      graph_name: subject_uri)
  end

end