##
# Some utility methods.
#
module LP::Util
  class << self
 
    # Erase all the persisted data. 
    def flush_data
      LP::REDIS.flushall
    end

  end
end
