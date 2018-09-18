module Backend
  class Storage < ::System::RedisPool

    include Singleton

    def self.parse_config
      config = File.read("#{Rails.root}/config/backend_redis.yml")
      config = ERB.new(config).result(binding)
      config = YAML.load(config)
      config = config.fetch(Rails.env).symbolize_keys
      config.reverse_merge(
        :logger => Rails.logger
      )
    end

    def initialize
      config = self.class.parse_config
      super(config)
    end

    # Writes any Ruby object into the storage. Use +get_object+ to read it back in the
    # same state.
    def set_object(key, object)
      set(key, Marshal.dump(object))
    end

    # Reads object stored using +set_object+.
    def get_object(key)
      data = get(key)
      data && Marshal.load(data)
    end

    # Increment by a value and expire at the same time.
    def incrby_and_expire(key, value, expires_in)
      incrby(key, value)
      expire(key, expires_in.try(:to_i))
    end

  end
end
