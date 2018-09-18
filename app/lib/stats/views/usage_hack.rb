# Module for inprove the performance of the method `usage_progress_for_all_methods`
#
# Run two times the same method, first time collect all the keys from `mget`
# but don't call redis.
# After that, call the original `mget` with all the keys and assign `StorageCache` as `storage`.
# Finally run a second time the method using que cache.
module Stats::Views::UsageHack

  class NoStorageException < RuntimeError; end

  def storage
    raise NoStorageException if @storage.nil?
    @storage
  end

  def usage_for_all(methods, options)
    @storage = StorageFake.instance
    super(methods, options)
    fake_to_cache(storage.keys)
    super(methods, options)
  end

  private

  def fake_to_cache(keys)
    @storage = StorageCache.instance
    @storage.cache = map_cache(keys)
  end

  def map_cache(keys)
    cache = {}
    if keys.present?
      bs = Backend::Storage.instance
      values = bs.mget(*keys)

      keys.each_with_index do |key, index|
        cache[key] = values[index].to_i
      end
    end
    cache
  end


  class StorageCache < Stats::Storage

    attr_accessor :cache

    def keys
      @cache.keys
    end

    # Read the keys from cache
    def mget(*the_keys)
      @cache.values_at(*the_keys).compact
    end
  end

  class StorageFake < Stats::Storage

    attr_reader :cached_keys

    def keys
      @cached_keys
    end

    # Collect the new keys if doesn't exists
    # and return an Array with the same elements
    def mget(*new_keys)
      @cached_keys ||= []
      new_keys.each do |key|
        @cached_keys << key.to_s unless @cached_keys.include?(key.to_s)
      end

      Array.new(new_keys.count, 0)
    end
  end

end



