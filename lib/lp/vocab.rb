## 
# Used vocabularies that are not available through RDF::Vocab.
#
module LP
  module Vocab
    class << self

      def wdata
          @wdata ||= RDF::Vocabulary.new('https://www.wikidata.org/wiki/Special:EntityData/')
      end

      def wd
        @wd ||= RDF::Vocabulary.new('http://www.wikidata.org/entity/')
      end

      def wdt
        @wd ||= RDF::Vocabulary.new('http://www.wikidata.org/prop/direct/')
      end  

    end
  end
end