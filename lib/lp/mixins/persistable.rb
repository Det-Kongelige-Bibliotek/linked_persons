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

  ##
  # Persists the data of the resource
  # TODO: Decide if the meta graph should be persisted.
  #
  # @return self 
  #
  # @raise LP::Errors::CouldNotBeSaved - If the resource
  # could not be saved.
  def save
    unless redis.set(id, graph.to_ttl) && \
      redis.set(meta_id, metagraph.to_ttl)
      
      raise LP::Errors::CouldNotBeSaved, subject_uri
    end

    self
  end

  def saved?
    redis.exists(id) && redis.exists(meta_id)
  end

  def delete
    redis.del(id)
    redis.del(meta_id)
  end

  ##
  # If the resource is saved, fetch it from the
  # persisted data otherwise dereference and save it.
  #
  # @return self
  #
  # @raise LP::Errors::NotFound - Thrown if the 
  # resource could not be found.
  #
  # @raise LP::Errors::AlreadyExists - If the resource 
  # already fetched.
  def fetch_from_db_or_dereference!
    raise LP::Errors::AlreadyExists, subject_uri if exists?

    if saved?
      fetch_from_db
    elsif dereferencable?
      dereference
      save
    else
      raise LP::Errors::NotFound, subject_uri
    end

    self
  end


  ##
  # Fetches the resource from persisted data.
  #
  # @raise LP::Errors::NotFound - Thrown if the 
  # resource could not be found.
  def fetch_from_db
    
    content = redis.get(id)
    raise LP::Errors::NotFound, subject_uri unless content

    t = Time.now
    # create(StringIO.new(content), 'text/turtle') # Too slow.
    
    create(StringIO.new(''), 'text/turtle')
    
    RDF::Reader.for(:turtle).new(content) do |reader|
      reader.each_statement do |statement|
        graph << statement
      end
    end
    
    p Time.now - t

  end

end