class KBA::Person < RDF::LDP::RDFSource
  include KBA::Base
  include KBA::Aggregatable

  TYPE_URI = RDF::Vocab::SCHEMA.Person.freeze
  # TOPIC_URI = RDF::Vocab::FOAF.primaryTopic.freeze

  # include KBA::RDFSource

  ##
  # Creates the document for 
  # the resource with the given URI string.
  # 
  # @param [String] uri_str - URI string identifying
  # the resource that the document is about. 
  # 
  # @return self
  def create_from_uri_str(uri_str)

    resource = KBA::Resource.new(uri_str, @data)
    resource.dereference
    # TODO: Validate
    self.same_as_uris = resource.same_as_uris + [resource.subject_uri]

    graph << make_type_triple
    # graph << make_topic_triple(resource)
    # graph << resource.graph

    aggregate

    self          
  end

  def make_type_triple
    RDF::Statement(subject_uri, RDF.type, TYPE_URI, 
      graph_name: subject_uri)
  end

  # def make_topic_triple(resource)
  #   RDF::Statement(subject_uri, TOPIC_URI, resource.to_uri, 
  #     graph_name: subject_uri)
  # end

end