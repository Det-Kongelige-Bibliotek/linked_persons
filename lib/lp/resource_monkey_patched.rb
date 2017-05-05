# ##
# # The monkey-patched base class for LDPRs.
# # @see the original definition. 
# class RDF::LDP::Resource


#   ##
#   # 
#   # Method monkey patched to use
#   # an existing transaction.
#   #
#   # @abstract creates the resource
#   #
#   # @param [IO, File] input  input (usually from a Rack env's
#   #   `rack.input` key) used to determine the Resource's initial state.
#   # @param [#to_s] content_type  a MIME content_type used to interpret the
#   #   input. This MAY be used as a content type for the created Resource
#   #   (especially for `LDP::NonRDFSource`s).
#   #
#   # @yield gives a transaction (changeset) to collect changes to graph,
#   #  metagraph and other resources' (e.g. containers) graphs
#   # @yieldparam tx [RDF::Transaction]
#   # @return [RDF::LDP::Resource] self
#   #
#   # @raise [RDF::LDP::RequestError] when creation fails. May raise various
#   #   subclasses for the appropriate response codes.
#   # @raise [RDF::LDP::Conflict] when the resource exists
#   def create(input, content_type, transaction = nil,  &block)
#     raise Conflict if exists?

#     if transaction
#       create_transactionally(transaction, block)      
#     else
#       @data.transaction(mutable: true) do |transaction|
#         create_transactionally(transaction, block)
#       end
#     end

#     self

#   end

#   protected
  
#   ##
#   # @protected
#   #
#   def create_transactionally(transaction, block)
#     set_interaction_model(transaction)
#     block.call transaction if block_given?
#     set_last_modified(transaction)
#   end



# end
