##
# Mixin for generating SPAQRL queries to extract 
# relevant data from fetched RDF representations.
#
module LP::QueryMaker

  # class TargetProperty
  #   attr_reader :uri

  #   def initialize(arg={})
  #     self.uri = arg[:uri]
  #     @is_object_property = arg[:is_object_property]
  #     @is_localized = arg[:is_localized]
  #   end

  #   def is_localized?
  #     @is_localized
  #   end

  #   def is_object_property?
  #     @is_object_property
  #   end

  #   def to_s
  #     self.uri.to_s
  #   end
  # end

  # TODO: Language sensitive properties should be handled.
  TARGET_DATA_PROPERTIES = [ 
    RDF.type,
    RDF::Vocab::SCHEMA.name,
    RDF::Vocab::SCHEMA.description,
    RDF::Vocab::SKOS.altLabel,      # Alternative label
    LP::Vocab.wdt.P569,             # Date of birth
    LP::Vocab.wdt.P570,             # Date of death
    LP::Vocab.wdt.P742,             # Pseudonym
  ].freeze

  TARGET_OBJECT_PROPERTIES = [ 
    LP::Vocab.wdt.P19,  # Place of birth
    LP::Vocab.wdt.P20,  # Place of death
    LP::Vocab.wdt.P21,  # Gender
    LP::Vocab.wdt.P27,  # Country of citizenship
    LP::Vocab.wdt.P103, # Native language
    LP::Vocab.wdt.P106, # Occupation
    LP::Vocab.wdt.P1412 # Used language
  ].freeze


  ##
  # Generates a SPARQL query to extract relevant data
  # on a resource identified by `target_uri`.  
  #
  # @param [RDF::URI, String] target_uri - The URI that identify 
  # the target resource within the representation.
  # @return [String] A SPARQL query.
  def make_sparql_query(target_uri)
    make_construct_clause + make_where_clause(target_uri)
  end

  # @private
  def make_construct_clause
    "CONSTRUCT { #{make_construct_inner_clause} }"
  end

  def make_construct_inner_clause
    construct_subclauses(subject_uri).join(' ')
  end

  # @private
  def construct_subclauses(uri)
    subclauses_for_d_properties(uri) + construct_subclauses_for_o_properties(uri)    
  end

  # @private
  def construct_subclauses_for_o_properties(uri)
    subclauses_for_o_properties(uri, false)
  end


  # @private
  def make_where_clause(target_uri)
    "WHERE { #{make_where_inner_clause(target_uri)} }"
  end

  # @private
  def make_where_inner_clause(target_uri)
    where_subclauses(target_uri).map do |s| 
      "{ #{s} }"
    end.join(' UNION ')
  end

  def where_subclauses(uri)
    subclauses_for_d_properties(uri) + where_subclauses_for_o_properties(uri)    
  end

  # @private
  def subclauses_for_d_properties(uri)
    TARGET_DATA_PROPERTIES.map.with_index do |property, index|
      "<#{uri}> <#{property}> ?d#{index}."            
    end 
  end

  # @private
  def where_subclauses_for_o_properties(uri)
    subclauses_for_o_properties(uri, true)
  end

  # @private
  def subclauses_for_o_properties(uri, where_subclauses=false)
    TARGET_OBJECT_PROPERTIES.map.with_index do |property, index|
      name_variable = "?on#{index}"
      statement = "<#{uri}> <#{property}> ?o#{index}.
       ?o#{index} <#{RDF::Vocab::SCHEMA.name}> #{name_variable}."
      
      if where_subclauses
        statement += "FILTER ( lang(#{name_variable}) = 'en' 
                           || lang(#{name_variable}) = 'da' 
                           || lang(#{name_variable}) = '')"
      end

      statement 
    end 
  end

end