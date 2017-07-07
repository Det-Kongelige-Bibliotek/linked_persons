module LP
  class Resource < RDF::LDP::RDFSource
    include Base
    include Dereferencable
    include Persistable
  end
end