##
# Mixin for generating SPAQRL queries to extract 
# relevant data from fetched RDF representations.
#
module LP::QueryMaker

  TARGET_DATA_PROPERTIES = [ 
    RDF.type,
    RDF::Vocab::SCHEMA.name,
    RDF::Vocab::SCHEMA.description,
    RDF::Vocab::SKOS.altLabel,      # Alternative label
    LP::Vocab.wdt.P18,              # Image
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
    make_construct_patterns(subject_uri).join(' ')
  end

  # @private
  def make_construct_patterns(uri)
    make_patterns_for_d_properties(uri) \
    + make_patterns_for_o_properties(uri)    
  end

  # @private
  def make_where_clause(target_uri)
    "WHERE { #{make_where_inner_clause(target_uri)} }"
  end

  # @private
  def make_where_inner_clause(target_uri)
    make_where_patterns(target_uri).map do |s| 
      "{ #{s} }"
    end.join(' UNION ')
  end

  # @private
  def make_where_patterns(uri)
    make_patterns_for_d_properties(uri, true) \
    + make_patterns_for_o_properties(uri, true)    
  end

  # @private
  def make_patterns_for_d_properties(uri, where_patterns=false)
    TARGET_DATA_PROPERTIES.map.with_index do |property, index|
      variable = "?d#{index}"
      pattern = "<#{uri}> <#{property}> #{variable}."
      
      # Not appending a language filter for the image property,
      # as it links to URLs and the filter prevents the pattern 
      # from matching.
      if where_patterns && property != LP::Vocab.wdt.P18
        pattern += "FILTER ( lang(#{variable}) = 'en' 
                          || lang(#{variable}) = 'da' 
                          || lang(#{variable}) = '')"           
      end
      pattern
    end 
  end

  # @private
  def make_patterns_for_o_properties(uri, where_patterns=false)
    TARGET_OBJECT_PROPERTIES.map.with_index do |property, index|
      name_variable = "?on#{index}"
      pattern = "<#{uri}> <#{property}> ?o#{index}.
       ?o#{index} <#{RDF::Vocab::SCHEMA.name}> #{name_variable}."
      
      if where_patterns
        pattern += "FILTER ( lang(#{name_variable}) = 'en' 
                           || lang(#{name_variable}) = 'da' 
                           || lang(#{name_variable}) = '')"
      end
      pattern 
    end 
  end

end