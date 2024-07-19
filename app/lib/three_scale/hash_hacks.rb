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

    # Convert all keys to lowercase.
    def downcase_keys
      transform_keys { |key| key.downcase }
    end

    # In place version of +downcase_keys+
    def downcase_keys!
      transform_keys! {|key| key.downcase}
    end

    # Convert all keys to uppercase.
    def upcase_keys
      transform_keys { |key| key.upcase }
    end

    # In place version of +upcase_keys+
    def upcase_keys!
      transform_keys! { |key| key.upcase }
    end
  end
end
