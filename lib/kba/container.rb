##
#
class KBA::Container < RDF::LDP::Container
  include KBA::Encoding  

  ##
  # Populates the container with the elements to be dereferenced 
  # from the given URI strings. 
  # 
  # @example
  #   container = KBA::Container.new('http://example.org/my/container', RDF::Repository.new)
  #   container.create_with_uri_strs(['http://viaf.org/viaf/36915259', 'http://viaf.org/viaf/27203135'])
  #
  # @param [Array<String>] arg - A URI string or an array of URI strings.
  #
  # @return self
  #
  # @raise [KBA::BadParameters]
  def create_from_uri_strs(arg)

    uri_strs = Array(arg)

    # Raise a proper error if did not get an array of strings.
    unless uri_strs.size > 0 && uri_strs.all? { |uri_str| uri_str.is_a? String }
      raise KBA::Errors::BadParameters 
    end

    uri_strs.map do |uri_str|
      person_uri_str = "?uri=#{encode(uri_str)}"
      person = KBA::Person.new(person_uri_str, @data)
      person.create_from_uri_str(uri_str)
      
    end.each do |person|
      add_element person
    end

    self
    
  end

  ##
  # Add an element to the container
  #
  # @param [RDF::LDP::RDFSource] element
  # @return self
  #
  def add_element(element)
    graph << element.graph 
    add(element)
    self
  end

end # KBA::Container