module KBA::Dereferencable
  include KBA::Fetcher
    
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

  def dereferenced?
    @dereferenced ||= false
  end


  # def dereference
  #   @data.load(subject_uri, graph_name: subject_uri)
  #   @dereferenced = true
  #   create(StringIO.new(''), 'text/turtle') unless exists?
  # end

  def dereference
    raise KBA::Errors::AlreadyExists, subject_uri if exists?

    response = fetch(subject_uri.to_s)
    create(StringIO.new(response.body), response.content_type)
    @dereferenced = true
  end


end