require 'rack/ldp'

module LinkedPersons
end

# Using LP as an alias.
LP = LinkedPersons

require_relative 'lp/errors'
require_relative 'lp/vocab'

require_relative 'lp/mixins/base'
require_relative 'lp/mixins/encoding'
require_relative 'lp/mixins/fetcher'
require_relative 'lp/mixins/dereferencable'
require_relative 'lp/mixins/query_maker'
require_relative 'lp/mixins/aggregatable'

require_relative 'lp/resource'
require_relative 'lp/person'
require_relative 'lp/container'
