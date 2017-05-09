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
        <#{subject_uri}> schema:description ?description.
        <#{subject_uri}> wdt:P18 ?image.

        <#{subject_uri}> wdt:P19 ?placeOfBirth.
        ?placeOfBirth schema:name ?birthPlaceName.
        
        <#{subject_uri}> wdt:P20 ?placeOfDeath.
        ?deathOfBirth schema:name ?deathPlaceName.

        <#{subject_uri}> wdt:P21 ?gender.
        ?gender schema:name ?genderName.

        <#{subject_uri}> wdt:P27 ?countryOfCitizenship.
        ?countryOfCitizenship schema:name ?countryOfCitizenshipName.

        <#{subject_uri}> wdt:P569 ?dateOfBirth.
        <#{subject_uri}> wdt:P570 ?dateOfDeath.
        
        <#{subject_uri}> wdt:106 ?occupation.
        ?occupation schema:name ?occupationName.

        <#{subject_uri}> skos:altLabel ?asKnownAs.

        <#{subject_uri}> wdt:P742 ?pseudonym.

        <#{subject_uri}> wdt:P103 ?nativeLanguage.
        ?nativeLanguage schema:name ?nativeLanguageName.
        
        <#{subject_uri}> wdt:P1412 ?usedLanguage.
        ?usedLanguage schema:name ?usedLanguageName.
      }
      WHERE {

        { <#{resource.subject_uri}> a ?type. }
        UNION
        { 
          <#{resource.subject_uri}> schema:name ?name.
          FILTER ( lang(?name) = "en" 
                || lang(?name) = "da" 
                || lang(?name) = "")
        }        
        UNION
        { 
          <#{resource.subject_uri}> schema:description ?description. 
          FILTER ( lang(?description) = "en" 
                || lang(?description) = "da" 
                || lang(?description) = "") 
        }
        UNION
        { <#{resource.subject_uri}> wdt:P18 ?image. }
        UNION
        { 
          <#{resource.subject_uri}> wdt:P19 ?placeOfBirth. 
          ?placeOfBirth schema:name ?birthPlaceName.
          FILTER ( lang(?birthPlaceName) = "en" 
                || lang(?birthPlaceName) = "da" 
                || lang(?birthPlaceName) = "") 
        }
        UNION
        { 
          <#{resource.subject_uri}> wdt:P20 ?placeOfDeath. 
          ?placeOfDeath schema:name ?placeOfDeathName. 
          FILTER ( lang(?deathPlaceName) = "en" 
                || lang(?deathPlaceName) = "da" 
                || lang(?deathPlaceName) = "")          
        }
        UNION
        { 
          <#{resource.subject_uri}> wdt:P21 ?gender. 
          ?gender schema:name ?genderName.
          FILTER ( lang(?genderName) = "en" 
              || lang(?genderName) = "da" 
              || lang(?genderName) = "")
        }
        UNION
        { 
          <#{resource.subject_uri}> wdt:P27 ?countryOfCitizenship. 
          ?countryOfCitizenship schema:name ?countryOfCitizenshipName.
          FILTER ( lang(?countryOfCitizenshipName) = "en" 
                || lang(?countryOfCitizenshipName) = "da" 
                || lang(?countryOfCitizenshipName) = "")
        }
        UNION
        { <#{resource.subject_uri}> wdt:P569 ?dateOfBirth. }
        UNION
        { <#{resource.subject_uri}> wdt:P570 ?dateOfDeath. }
        UNION
        { 
          <#{resource.subject_uri}> wdt:106 ?occupation. 
          ?occupation schema:name ?occupationName.
          FILTER ( lang(?occupationName) = "en" 
                || lang(?occupationName) = "da" 
                || lang(?occupationName) = "")
        }
        UNION
        { 
          <#{resource.subject_uri}> skos:altLabel ?asKnownAs. 
          FILTER ( lang(?asKnownAs) = "en" 
                || lang(?asKnownAs) = "da" 
                || lang(?asKnownAs) = "")
        }
        UNION
        { 
          <#{resource.subject_uri}> wdt:P742 ?pseudonym. 
          FILTER ( lang(?pseudonym) = "en" 
                || lang(?pseudonym) = "da" 
                || lang(?pseudonym) = "")
        }
        UNION
        { 
          <#{resource.subject_uri}> wdt:P103 ?nativeLanguage. 
          ?nativeLanguage schema:name ?nativeLanguageName.
          FILTER ( lang(?nativeLanguageName) = "en" 
                || lang(?nativeLanguageName) = "da" 
                || lang(?nativeLanguageName) = "")
        }
        UNION
        { 
          <#{resource.subject_uri}> wdt:P1412 ?usedLanguage.
          ?usedLanguage schema:name ?usedLanguageName.
          FILTER ( lang(?usedLanguageName) = "en" 
                || lang(?usedLanguageName) = "da" 
                || lang(?usedLanguageName) = "")

        }
        
      }
    )
    statements = SPARQL.execute(query, resource.graph)
    statements.each do |statement|
 
      statement.graph_name = subject_uri
      graph << statement
 
    end

  end


end