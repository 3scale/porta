module Stats
  module Aggregation
    class Rule
      include Stats::KeyHelpers

      def initialize(*args, &block)
        @options = args.extract_options!
        @options.assert_valid_keys(:metric, :granularity, :expires_in)

        @keys = args
      end

      def aggregate(data)
        update_accumulator(data)
        update_source_set(data)
      end

      def expires_in
        @options[:expires_in]
      end

      def volatile?
        !expires_in.nil?
      end

      private

      def update_accumulator(data)
        data[:usage].each do |metric_id, value|
          key = accumulator_key(data, :metric, metric_id)

          if volatile?
            storage.incrby_and_expire(key, value, expires_in.to_i)
          else
            storage.incrby(key, value)
          end
        end
        if data[:log] && (value = data[:log].with_indifferent_access['code'])
          key = accumulator_key(data, :response_code, value )
          storage.incrby(key, 1)

          group_key = accumulator_key(data, :response_code, "#{value/100}XX")
          storage.incrby(group_key, 1)
        end
      end

      def update_source_set(data)
        return if @keys.size < 2

        source_name  = @keys.last
        source_value = data[source_name]

        key = source_set_key_prefix(data) + '/' +
              source_name.to_s.pluralize.underscore

        storage.sadd(key, encode_key(source_value.to_param))
      end

      def accumulator_key(data, type, id)
        domain_key_component(data, @keys) + '/' +
          key_component(type, id) + '/' +
          granularity_key_component(data)
      end

      def source_set_key_prefix(data)
        domain_key_component(data, @keys[0..-2])
      end

      def domain_key_component(data, keys)
        keys.inject(:stats) do |memo, name|
          key_for(memo, name => data[name])
        end
      end

      def key_component(type,id)
        key_for(type => id)
      end

      def granularity_key_component(data)
        if granularity == :eternity
          "eternity"
        else
          cycle = data[:created_at].beginning_of_cycle(granularity)
          key_for(granularity => cycle.to_s(:compact))
        end
      end

      def granularity
        Aggregation.normalize_granularity(@options[:granularity])
      end

      def storage
        Stats::Base.storage
      end
    end
  end
end
