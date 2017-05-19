##
# Mixin for persistence.
#
module LP::Persistable
  
  def redis
    LP::REDIS
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def persistable?
      true
    end

  end

  def persistable?
    true
  end

  def id
    graph.name.to_s
  end

  def meta_id
    metagraph.name.to_s
  end

  # TODO: Decide if the meta graph should be persisted.
  def save
    redis.set(id, graph.to_ttl)
    redis.set(meta_id, metagraph.to_ttl)
  end

  def saved?
    redis.exists(id) && redis.exists(meta_id)
  end

  def delete
    redis.del(id)
    redis.del(meta_id)
  end

  ##
  # Creates the resource with persisted data.
  #
  # @raise LP::Errors::NotFound - Thrown if the 
  # resource could not be found.
  def create_with_persisted_data
    
    content = redis.get(id)
    raise LP::Errors::NotFound unless content

    t = Time.now
    # create(StringIO.new(content), 'text/turtle') # Too slow.
    
    create(StringIO.new(''), 'text/turtle')
    
    RDF::Reader.for(:turtle).new(content)do |reader|
      reader.each_statement do |statement|
        graph << statement
      end
    end
    
    p Time.now - t

  end

  ##
  # If the resource is saved, create it with 
  # the persisted data otherwise dereference 
  # and save it.
  #
  # @raise LP::Errors::NotFound - Thrown if the 
  # resource could not be found.
  #
  # @raise LP::Errors::AlreadyExists - If the resource 
  # already exists.
  def create_with_persisted_or_dereference
    raise LP::Errors::AlreadyExists, subject_uri if exists?

    if saved?
      create_with_persisted_data
    elsif dereferencable?
      dereference
      save
    else
      raise LP::Errors::NotFound
    end
  end

end