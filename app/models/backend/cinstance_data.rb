module Backend
  # This class holds various auxiliary data for a cinstance, necessary for transaction processing.
  class CinstanceData
    attr_reader :provider_account_id
    attr_reader :cinstance_id
    attr_reader :service_id

    def initialize(provider_account, cinstance, service)

      # If we got object which responds to id - it is AR object
      # we wan't to cache it and do not query DB again
      # but in case it is id, we will load it - check #provider_account and others

      if cinstance.respond_to?(:id)
        @cinstance = cinstance
      else
        @cinstance_id = cinstance
      end

      if provider_account.respond_to?(:id)
        @provider_account = provider_account
      else
        @provider_account_id = provider_account
      end

      if service.respond_to?(:id)
        @service = service
      else
        @service_id = service
      end
    end

    def provider_account_id
      @provider_account_id ||= @provider_account.try!(:id)
    end

    def cinstance_id
      @cinstance_id ||= @cinstance.try!(:id)
    end

    def validate_state!
      case data[:cinstance_state]
      when 'live' then true
      when 'unpaid' then raise CreditExceeded
      else
        raise ContractNotActive
      end
    end

    def process_usage(raw_usage)
      usage = parse_usage(raw_usage)
      usage.keys.dup.each do |metric_id|
        (data[:metric_ancestors][metric_id] || []).each do |ancestor_metric_id|
          usage[ancestor_metric_id] ||= 0
          usage[ancestor_metric_id] += usage[metric_id]
        end
      end

      usage
    end

    def process_usages(raw_transactions)
      errors = {}

      usages = raw_transactions.inject({}) do |usages, raw_transaction|
        begin
          usages[raw_transaction[:index]] = process_usage(raw_transaction[:usage])
        rescue Error => exception
          errors[raw_transaction[:index]] = exception.code
        end

        usages
      end

      raise MultipleErrors, errors unless errors.empty?
      usages
    end

    def usage_accumulator
      @usage_accumulator ||= UsageAccumulator.new(provider_account_id, cinstance_id, data)
    end

    def anonymous_clients_allowed?
      data[:anonymous_clients_allowed]
    end

    def status(options = {})
      Status.new(data, usage_accumulator.values, options)
    end

    def provider_verification_key
      data[:provider_verification_key]
    end

    def plan_name
      data[:plan_name]
    end

    def application_id
      data[:application_id]
    end

    private

    def data
      @data ||= load_data
    end

    def load_data

      data, options = {}, {}

      metrics = service.metrics

      data[:metric_ids] = metrics.ids_indexed_by_names
      data[:metric_ancestors] = metrics.ancestors_ids
      #TODO: multiservice
      data[:service_id] = service.id

      if provider_account.feature_allowed?(:anonymous_clients)
        data[:anonymous_clients_allowed] = true
      else
        data[:application_id] = cinstance.application_id

        # TODO: remove - deprecated
        data[:billing] = nil

        data[:buyer_account_id] = cinstance.user_account_id
        data[:buyer_currency] = cinstance.user_account.currency
        data[:cinstance_id] = cinstance_id
        data[:cinstance_state] = cinstance.state
        data[:plan_name] = cinstance.plan.name
        data[:provider_verification_key] = cinstance.provider_public_key
        data[:usage_limits] = cinstance.plan.usage_limits.to_a
        data[:pricing_rules] = cinstance.plan.pricing_rules.group_by(&:metric_id)
        data[:provider_currency] = provider_account.currency

        if cinstance.trial?
          data[:billing] = :trial
          options[:expires_in] = cinstance.remaining_trial_period_seconds
        end
      end

      data
    end

    def provider_account
      @provider_account ||= Account.find(provider_account_id)
    end

    def service
      @service ||= Service.find(@service_id)
    end

    def cinstance
      @cinstance ||= provider_account.provided_cinstances.find(cinstance_id)
    rescue ActiveRecord::RecordNotFound
      raise UserKeyInvalid
    end

    def parse_usage(raw_usage)
      (raw_usage || {}).inject(NumericHash.new) do |usage, (name, value)|
        metric_id = data[:metric_ids][name.downcase]
        raise MetricNotFound unless metric_id
        raise UsageValueInvalid unless value.is_a?(Numeric) || value.to_s =~ /\A\s*\d+\s*\Z/

        usage.update(metric_id => value.to_i)
      end
    end
  end
end

