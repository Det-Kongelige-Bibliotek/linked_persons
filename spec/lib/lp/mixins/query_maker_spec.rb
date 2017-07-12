require 'spec_helper'

RSpec.describe LP::QueryMaker do
  describe '#make_sparql_query' do

    let(:subject_uri) { RDF::URI('http://dummy.subject.uri') }
    let(:target_uri) { RDF::URI('http://www.wikidata.org/entity/Q1607626') }

    let(:dummy_instance) do 
      dummy_class = Class.new do 
        include LP::QueryMaker 

        def subject_uri
          RDF::URI('http://dummy.subject.uri')
        end
      end

      dummy_class.new 
    end

    let(:sample_data) do
      '''
        @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
        @prefix wd: <http://www.wikidata.org/entity/> .
        @prefix wdt: <http://www.wikidata.org/prop/direct/> .
        @prefix wikibase: <http://wikiba.se/ontology-beta#> .
        @prefix schema: <http://schema.org/> .

        wd:Q1607626 a wikibase:Item ;
          schema:name "Paul Lacroix"@fr, "Paul Lacroix"@en, "Paul Lacroix"@da;
          schema:description "French author (1806-1884)"@en,
            "historien et bibliographe, journaliste, romancier"@fr;
          wdt:P27 wd:Q142.

        wd:Q142 a wikibase:Item ;
          schema:name "France"@en, "France"@fr, "Frankrig"@da.'''
    end

    let(:sample_graph) do
      graph = RDF::Graph.new
      RDF::Reader.for(:turtle).new(sample_data) do |reader|
        reader.each_statement do |statement|
          graph << statement
        end
      end
      graph
    end

    it 'generates a functional Sparql Construct query' do       
      query = dummy_instance.make_sparql_query(target_uri)
      constructed_graph = SPARQL.execute(query, sample_graph)
      expect(constructed_graph.size).to be > 0
    end
  end
end
