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

    # This is a copy of ActiveSupport 5.1 #deep_merge and #deep_merge! where current Hash gets its block called
    #   for each key present in the other_hash. On some places we rely on this behavior by creating a Hash
    #   like `Hash.new { |hash, key| hash[key] = Set.new }`, then expect other_hash'es elements to merge with that
    #   default value.
    # See https://github.com/rails/rails/commit/2eacb1c30eac4058b8412527f9bda6e7ba6103d4
    # TODO: use a better approach
    def deep_merge_forcing_default_value(other_hash, &block)
      dup.deep_merge_forcing_default_value!(other_hash, &block)
    end

    def deep_merge_forcing_default_value!(other_hash, &block)
      other_hash.each_pair do |current_key, other_value|
        this_value = self[current_key]

        self[current_key] = if this_value.is_a?(Hash) && other_value.is_a?(Hash)
                              this_value.deep_merge_forcing_default_value(other_value, &block)
                            else
                              if block_given? && key?(current_key)
                                block.call(current_key, this_value, other_value)
                              else
                                other_value
                              end
                            end
      end

      self
    end

    def sweep
      # no op, just to prevent airbrake
      # rails things hash is a flashhash
    end

    # TODO: remove after migration to ruby 2.5+ and replace it with transform_keys
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
    # TODO replace with transform_keys {|key| key.downcase}
    def downcase_keys
      map_keys { |key| key.downcase }
    end

    # In place version of +downcase_keys+
    def downcase_keys!
      replace(downcase_keys)
    end

    # Convert all keys to uppercase.
    # TODO replace with transform_keys {|key| key.upcase}
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
  end
end
