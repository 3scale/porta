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
