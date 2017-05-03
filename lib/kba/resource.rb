# TODO: 
# - A selected number of semantic queries should be run 
# on the retrieved data to yield the desired data on each author.
#   - Including the co-authorship information.
#   - Discarding data in all languages but English and Danish.
#  

class KBA::Resource < RDF::LDP::RDFSource
  include KBA::Base
  include KBA::Dereferencable
end