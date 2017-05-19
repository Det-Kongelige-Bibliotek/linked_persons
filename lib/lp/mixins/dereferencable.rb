module LP::Dereferencable
  include LP::Fetcher
    
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def dereferencable?
      true
    end

  end

  def dereferencable?
    true
  end

  # TODO: Where is this really needed?
  # Should we depend on `exists?` instead?      
  def dereferenced?
    @dereferenced ||= false
  end


  # def dereference
  #   @data.load(subject_uri, graph_name: subject_uri)
  #   @dereferenced = true
  #   create(StringIO.new(''), 'text/turtle') unless exists?
  # end


  ##
  # Dereference the resource
  #
  # @raise LP::Errors::AlreadyExists - If the resource 
  # already exists.
  def dereference
    raise LP::Errors::AlreadyExists, subject_uri if exists?

    response = fetch(subject_uri.to_s)
    create(StringIO.new(response.body), response.content_type)
    @dereferenced = true
  end


end