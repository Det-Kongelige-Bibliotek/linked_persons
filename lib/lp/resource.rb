# TODO: 
# - A selected number of semantic queries should be run 
# on the retrieved data to yield the desired data on each author.
#   - Including the co-authorship information.
#   - Discarding data in all languages but English and Danish.
#  

class LP::Resource < RDF::LDP::RDFSource
  include LP::Base
  include LP::Dereferencable
end