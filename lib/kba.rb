require 'rack/ldp'

module KBA
end

require_relative 'kba/errors'
require_relative 'kba/vocab'

require_relative 'mixins/base'
require_relative 'mixins/encoding'
require_relative 'mixins/fetcher'
require_relative 'mixins/dereferencable'
require_relative 'mixins/aggregatable'

require_relative 'kba/resource'
require_relative 'kba/person'
require_relative 'kba/container'
