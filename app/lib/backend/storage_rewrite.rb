module Backend
  module StorageRewrite


    module_function

    def rewrite_all
      total_count = Service.count + Cinstance.count + Metric.count + UsageLimit.count
      progress_each = 100
      index = 0

      progress = lambda do
        index += 1
        break unless (index % progress_each) == 0
        percent = (index / total_count.to_f) * 100.0

        yield percent if block_given?
      end

      Service.find_each do |service|
        service.update_backend_service
        progress.call
        service.service_tokens.find_each(&ServiceTokenService.method(:update_backend))
      end

      Cinstance.find_each do |cinstance|
        cinstance.send(:update_backend_application)
        cinstance.send(:update_backend_user_key_to_application_id_mapping)

        # to ensure that there is a 'backend_object' - there are
        # invalid data floating around
        if cinstance.provider_account
          cinstance.application_keys.each { |k| k.send(:update_backend_value) }
          cinstance.referrer_filters.each { |f| f.send(:update_backend_value) }
        end

        progress.call
      end

      Metric.find_each do |metric|
        metric.send(:sync_backend!)
        progress.call
      end

      UsageLimit.find_each do |usage_limit|
        usage_limit.send(:update_backend_usage_limit)
        progress.call
      end
    end

    def rewrite_provider(id)
      provider = Account.providers_with_master.find(id)

      services = provider.services.includes(:account)
      cinstances = provider.buyer_applications.includes(:plan, :service)

      if (cinstance_id = ENV['CINSTANCE_ID'])
        cinstances = cinstances.where(id: cinstance_id)
      end

      bought_cinstances = provider.bought_cinstances

      metrics = provider.metrics.includes(:service, :parent)
      usage_limits = provider.usage_limits.includes(plan: :service)

      total_count = services.size + cinstances.size + metrics.size + usage_limits.size + bought_cinstances.size

      index = 0
      progress = lambda do
        percent = ((index + 1) / total_count.to_f) * 100.0
        yield percent if block_given?
        index += 1
      end

      services.find_each do |service|
        service.update_backend_service
        progress.call

        service.service_tokens.find_each(&ServiceTokenService.method(:update_backend))
      end

      metrics.find_each do |metric|
        metric.send(:sync_backend!)
        progress.call
      end

      usage_limits.find_each do |usage_limit|
        usage_limit.send(:update_backend_usage_limit)
        progress.call
      end

      update_cinstance = lambda do |cinstance|
        cinstance.send(:update_backend_application)
        cinstance.send(:update_backend_user_key_to_application_id_mapping)
        if cinstance.provider_account
          cinstance.application_keys.each { |k| k.send(:update_backend_value) }
          cinstance.referrer_filters.each { |f| f.send(:update_backend_value) }
        end
        progress.call
      end

      cinstances.find_each(&update_cinstance)
      bought_cinstances.find_each(&update_cinstance)
    end
  end
end
