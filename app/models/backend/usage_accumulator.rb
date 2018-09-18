module Backend
  # This class provides convenient access to the accumulated usage data for a cinstance.
  class UsageAccumulator
    include Stats::KeyHelpers

    include ThreeScale::Benchmark

    def initialize(provider_account_id, cinstance_id, cinstance_data)
      @provider_account_id = provider_account_id
      @cinstance_id = cinstance_id
      @cinstance_data = cinstance_data
    end

    def validate!(options = {})
      validate_limits!(options)
      validate_credit!(options)
    end

    def values
      @values ||= compile_values
    end

    private

    attr_reader :provider_account_id
    attr_reader :cinstance_id
    attr_reader :cinstance_data

    def compile_values
      periods = (cinstance_data[:usage_limits].map(&:period) + [:month]).uniq
      metric_ids = cinstance_data[:metric_ids].values

      flat_values = read_values_from_storage(periods, metric_ids)
      structuralize_values(flat_values, periods, metric_ids)
    end

    def read_values_from_storage(periods, metric_ids)
      benchmark "[Usage] Loading usage for #{metric_ids.count} metrics" do
        Stats::Base.storage.mget(*storage_keys(periods, metric_ids)).map(&:to_i)
      end
    end

    def structuralize_values(flat_values, periods, metric_ids)
      # The values are in flat array. Convert them into hash of periods (Symbols)
      # mapped to NumericHashes.
      #
      # TODO: extract this into something like Array#unflatten

      values = {}
      index  = 0

      periods.each do |period|
        values_for_period = NumericHash.new

        metric_ids.each do |metric_id|
          values_for_period[metric_id] = flat_values[index]
          index += 1
        end

        values[period] = values_for_period
      end

      values
    end

    def storage_keys(periods, metric_ids)
      benchmark "[Usage] generating keys" do
        periods.map do |period|
          metric_ids.map do |metric_id|
            storage_key(period, metric_id)
          end
        end.flatten
      end
    end

    def storage_key(period, metric_id)
      key_for(:stats, {:service   => cinstance_data[:service_id]},
                      {:cinstance => cinstance_data[:application_id]},
                      {:metric    => metric_id},
                      {period     => Time.zone.now.beginning_of(period).to_s(:compact)})
    end

    def validate_limits!(options)
      additional_usage = options[:additional_usage] || NumericHash.new

      violated_limits = cinstance_data[:usage_limits].select do |usage_limit|
        values_in_period = values[usage_limit.period]

        value = values_in_period && values_in_period[usage_limit.metric_id]
        value = value.to_i + additional_usage[usage_limit.metric_id].to_i

        value > usage_limit.value
      end

      unless violated_limits.empty?
        raise LimitsExceeded
      end
    end

    def validate_credit!(options)
      if cinstance_data[:billing] == :prepaid
        total_cost = calculate_total_cost(options).values.sum
        total_cost = total_cost.to_money(cinstance_data[:provider_currency])
      end
    end

    def calculate_cost_of(usage)
      if cinstance_data[:billing] == :trial
        NumericHash.new
      else
        calculate_total_cost_of(values[:month] + usage) - calculate_total_cost_of(values[:month])
      end
    end

    def calculate_total_cost_of(usage)
      usage.inject(NumericHash.new) do |total_cost, (metric_id, value)|
        if pricing_rules = cinstance_data[:pricing_rules][metric_id]
          total_cost[metric_id] = pricing_rules.sum do |pricing_rule|
            pricing_rule.cost_for_value(value)
          end
        end

        total_cost
      end
    end

    def calculate_total_cost(options)
      total_values = values[:month]
      total_values += options[:additional_usage] if options[:additional_usage]

      calculate_total_cost_of(total_values)
    end
  end
end

