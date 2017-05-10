module LP::QueryMaker

  SOURCE_URI_ROOTS = [ 
    'http://www.wikidata.org/', 
    'https://www.wikidata.org/',
    'http://viaf.org/',
    'https://viaf.org/', 
  ].freeze


  # TODO: Language sensitive properties should be handled.

  TARGET_DATA_PROPERTIES = [ 
    RDF.type,
    RDF::Vocab::SCHEMA.name,
    RDF::Vocab::SCHEMA.description,
    RDF::Vocab::SKOS.altLabel,
    LP::Vocab.wdt.P569,
    LP::Vocab.wdt.P570,
    LP::Vocab.wdt.P742,
  ].freeze

  TARGET_OBJECT_PROPERTIES = [ 
    LP::Vocab.wdt.P19,
    LP::Vocab.wdt.P20,
    LP::Vocab.wdt.P21,
    LP::Vocab.wdt.P27,
    LP::Vocab.wdt.P103,
    LP::Vocab.wdt.P106,
    LP::Vocab.wdt.P1412
  ].freeze

  def subclauses_for_data_properties(uri)
    TARGET_DATA_PROPERTIES.map.with_index do |property, index|
      %({
        <#{uri}> <#{property}> ?d#{index}.

      })            
    end 
  end

def subclauses_for_object_properties(uri)
    TARGET_OBJECT_PROPERTIES.map.with_index do |property, index|
      %({
        <#{uri}> <#{property}> ?o#{index}.
        ?o#{index} <#{RDF::Vocab::SCHEMA.name}> ?on#{index}. 
      })            
    end 
  end
  

  def where_clause
    %(
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
        ?nativeLanguageProperty wikibase:directClaim wdt:P103.
        ?nativeLanguageProperty schema:name ?nativeLanguagePropertyName.
        FILTER ( lang(?nativeLanguagePropertyName) = "en" 
              || lang(?nativeLanguagePropertyName) = "da" 
              || lang(?nativeLanguagePropertyName) = "")
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

  end


  def make_sparql_query(source_uri, target_uri)

    query =  %(
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
        ?nativeLanguageProperty wikibase:directClaim wdt:P103.
        ?nativeLanguageProperty schema:name ?nativeLanguagePropertyName.

        <#{subject_uri}> wdt:P1412 ?usedLanguage.
        ?usedLanguage schema:name ?usedLanguageName.
      }

    #{where_clause}
    )

  end


end
