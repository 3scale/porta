# frozen_string_literal: true

class Redis
  def self.new_with_namespace(options = {})
    namespace = options[:namespace].presence
    redis = new(options)
    namespace ? Redis::Namespace.new(namespace, redis: redis) : redis
  end
end
