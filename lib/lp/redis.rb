require 'redis'

module LP
  unless ENV['REDIS_PORT'].nil?
    redis_path_array = ENV['REDIS_PORT'].split(':')
    REDIS_PORT = redis_path_array.pop.to_i.freeze
    REDIS_HOST = redis_path_array[1].split('//').last.freeze

    REDIS = Redis.new(host: REDIS_HOST, port: REDIS_PORT)
  end
end
