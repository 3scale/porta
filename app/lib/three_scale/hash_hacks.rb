#
# TODO: investigate why we need this
module ThreeScale

  module HashHacks
    MissingKeyError = Class.new(ArgumentError)

    # backport from activesupport 4.2
    unless Hash.public_method_defined?(:transform_values)
      def transform_values
        return enum_for(:transform_values) unless block_given?
        result = self.class.new
        each do |key, value|
          result[key] = yield(value)
        end
        result
      end
    end

    def sweep
      # no op, just to prevent airbrake
      # rails things hash is a flashhash
    end

    # Pass all values through block
    def map_values(&block) #:yield:
      dup.map_values!(&block)
    end

    def map_values! #:yield:
      each do |key, value|
        self[key] = yield(value)
      end

      self
    end

    def map_keys
      inject(self.class.new) do |memo, (key, value)|
        memo[yield(key)] = value
        memo
      end
    end

    def map_keys!(&block)
      replace(map_keys(&block))
    end

    # Convert all keys to lowercase.
    def downcase_keys
      map_keys { |key| key.downcase }
    end

    # In place version of +downcase_keys+
    def downcase_keys!
      replace(downcase_keys)
    end

    # Convert all keys to uppercase.
    def upcase_keys
      inject(self.class.new) do |memo, (key, value)|
        memo[key.upcase] = value
        memo
      end
    end

    # In place version of +upcase_keys+
    def upcase_keys!
      replace(upcase_keys)
    end

    # Assert that the hash contains all the given keys.
    def assert_required_keys!(*required)
      missing = required.select do |req| # this implementation was changed from using self.keys as it didn't work with HashWithIndifferentAccess
        self[req].nil?
      end
      raise MissingKeyError, "Missing key(s): #{missing.to_sentence}" unless missing.empty?
    end

    alias assert_required_keys assert_required_keys!
  end

  module OrderedHashHacks
    # Clones ordered hash and its values.
    #
    # TODO: can it be simply replaced by #dup or #clone?
    #
    def deep_clone
      cloned = ActiveSupport::OrderedHash.new
      self.each { |key, value| cloned[key] = value.dup }
      cloned
    end

    def sort_keys
      keys.sort.inject(self.class.new) do |memo, key|
        memo[key] = self[key]
        memo
      end
    end
  end
end
