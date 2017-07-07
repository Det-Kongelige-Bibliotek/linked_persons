##
# Some utility methods.
#
module LP
  module Util
    module_function
     
    # Erase all the persisted data. 
    def flush_data
      REDIS.flushall
    end

  end
end