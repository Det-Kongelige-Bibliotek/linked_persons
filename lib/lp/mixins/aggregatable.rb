module LP::Aggregatable
  
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

  def aggregate

    source_uris.each do |uri|
      # resource = LP::Resource.new(uri, @data)
      resource = LP::Resource.new(uri, RDF::Repository.new)
      
      begin
        resource.dereference
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

    # query = "SELECT * WHERE {?s ?p ?o}"
    query =  %(
      PREFIX wdata: <https://www.wikidata.org/wiki/Special:EntityData/>
      PREFIX wd: <http://www.wikidata.org/entity/> 
      PREFIX wdt: <http://www.wikidata.org/prop/direct/> 
      PREFIX schema: <http://schema.org/> 
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#> 
      PREFIX foaf:    <http://xmlns.com/foaf/0.1/>

      CONSTRUCT { 
        <#{subject_uri}> a ?type.
        <#{subject_uri}> schema:name ?name.
        <#{subject_uri}> wdt:P18 ?image.
      }
      WHERE {
        <#{resource.subject_uri}> a ?type.
        <#{resource.subject_uri}> schema:name ?name.
        <#{resource.subject_uri}> schema:description ?description.
        <#{resource.subject_uri}> wdt:P18 ?image.
        <#{resource.subject_uri}> wdt:P19 ?placeOfBirth.
        <#{resource.subject_uri}> wdt:P20 ?placeOfDeath.
        <#{resource.subject_uri}> wdt:P21 ?gender.
        <#{resource.subject_uri}> wdt:P27 ?countryOfCitizenship.
        <#{resource.subject_uri}> wdt:P569 ?dateOfBirth.
        <#{resource.subject_uri}> wdt:P570 ?dateOfDeath.
        <#{resource.subject_uri}> wdt:106 ?occupation.
        <#{resource.subject_uri}> skos:altLabel ?asKnownAs.
        <#{resource.subject_uri}> wdt:P742 ?pseudonym.
        <#{resource.subject_uri}> wdt:P103 ?nativeLanguage.
        <#{resource.subject_uri}> wdt:P1412 ?usedLanguage.

        ?placeOfBirth schema:name ?birthPlaceName.
        ?placeOfDeath schema:name ?deathPlaceName.
        ?gender schema:name ?genderName.
        ?countryOfCitizenship schema:name ?countryOfCitizenshipName.
        ?occupation schema:name ?occupationName.
        ?nativeLanguage schema:name ?nativeLanguageName.
        ?usedLanguage schema:name ?usedLanguageName.

        FILTER ( lang(?name) = "en" 
              || lang(?name) = "da" 
              || lang(?name) = "")
        FILTER ( lang(?birthPlaceName) = "en" 
              || lang(?birthPlaceName) = "da" 
              || lang(?birthPlaceName) = "")
        FILTER ( lang(?deathPlaceName) = "en" 
              || lang(?deathPlaceName) = "da" 
              || lang(?deathPlaceName) = "")
        FILTER ( lang(?genderName) = "en" 
              || lang(?genderName) = "da" 
              || lang(?genderName) = "")
        FILTER ( lang(?countryOfCitizenshipName) = "en" 
              || lang(?countryOfCitizenshipName) = "da" 
              || lang(?countryOfCitizenshipName) = "")
        FILTER ( lang(?occupationName) = "en" 
              || lang(?occupationName) = "da" 
              || lang(?occupationName) = "")
        FILTER ( lang(?nativeLanguageName) = "en" 
              || lang(?nativeLanguageName) = "da" 
              || lang(?nativeLanguageName) = "")
        FILTER ( lang(?usedLanguageName) = "en" 
              || lang(?usedLanguageName) = "da" 
              || lang(?usedLanguageName) = "")
        }
    )
    statements = SPARQL.execute(query, resource.graph)
    statements.each do |statement|
 
      statement.graph_name = subject_uri
      graph << statement
 
    end

  end


end