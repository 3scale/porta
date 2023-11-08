# frozen_string_literal: true

require 'progress_counter'

module Backend

  module StorageRewrite

    # Rewriter and its subclasses perform operations that update the objects on 3scale Backend
    class Rewriter
      # Rewrite a collection
      # @param scope [ActiveRecord::Associations::CollectionProxy] ActiveRecord collection with filtered scope
      # @param ids [Array] Array of IDs belonging to scope or class
      # @param log_progress [Boolean] specifies whether to print progress to console
      def self.rewrite(**kwargs)
        scope = kwargs[:scope] || self::CLASS
        ids = kwargs[:ids]
        scope = scope.where(id: ids) if ids.present?
        log_progress = kwargs[:log_progress] || false
        progress = log_progress ? ProgressCounter.new(scope.count) : nil

        scope.includes(self::INCLUDE).find_each do |model|
          self::REWRITER.call(model)
          progress&.call
        end
      end
    end

    class CinstanceRewriter < Rewriter
      CLASS = Cinstance
      INCLUDE = %i[plan service].freeze
      REWRITER = ->(cinstance) do
        cinstance.send(:update_backend_application)
        cinstance.send(:update_backend_user_key_to_application_id_mapping)
        # to ensure that there is a 'backend_object' - there are
        # invalid data floating around
        if cinstance.provider_account
          cinstance.application_keys.each { |app_key| app_key.send(:update_backend_value) }
          cinstance.referrer_filters.each { |ref_filter| ref_filter.send(:update_backend_value) }
        end
      end
    end

    class ServiceRewriter < Rewriter
      CLASS = Service
      INCLUDE = :account
      REWRITER = ->(service) do
        service.update_backend_service
        service.service_tokens.find_each(&ServiceTokenService.method(:update_backend))
      end
    end

    class MetricRewriter < Rewriter
      CLASS = Metric
      INCLUDE = :parent
      REWRITER = ->(metric) { metric.sync_backend! }
    end

    class UsageLimitRewriter < Rewriter
      CLASS = UsageLimit
      INCLUDE = { plan: :service }.freeze
      REWRITER = ->(usage_limit) { usage_limit.update_backend_usage_limit }
    end

    # Used for rewriting all objects inline, and also. `#rewrite` is used by async jobs
    class Processor

      attr_reader :include_inactive, :log_progress, :action

      # @param include_inactive [Boolean] specifies whether to include deleted and suspended providers
      # @param log_progress [Boolean] specifies whether to print progress to console
      def initialize(**kwargs)
        @include_inactive = kwargs[:include_inactive] || false
        @log_progress = kwargs[:log_progress] || false
        @action = :rewrite
      end

      # Execute actual rewriting with Backend, depending on the class.
      # To be called from the async jobs
      # @param class_name [String] name of class (used by async jobs)
      # @param scope [ActiveRecord::Associations::CollectionProxy] ActiveRecord collection with filtered scope (used by sync processor)
      # @param log_progress [Boolean] specifies whether to print progress to console
      def rewrite(**kwargs)
        class_name = kwargs.delete(:class_name)
        klass = class_name || kwargs[:scope]&.klass&.name
        raise ArgumentError, ':class_name or :scope arguments must be provided' if klass.blank?

        rewriter = Backend::StorageRewrite.const_get("#{klass}Rewriter")
        rewriter.rewrite({ **kwargs, log_progress: log_progress})
      end

      # Schedule all objects for all providers, or execute inline
      def rewrite_all
        providers.each do |account|
          rewrite_provider(account.id)
        end
        nil
      end

      # Schedule a single provider or execute inline
      def rewrite_provider(id)
        logger.info "#{action} backend storage for provider #{id}..."

        provider = providers.find_by(id: id)
        unless provider
          logger.error("Provider with ID #{id} not found")
          return
        end

        logger.info "#{action} services for provider #{id}..."
        process(provider.services)

        logger.info "#{action} buyer applications for provider #{id}..."
        process(provider.buyer_applications)

        logger.info "#{action} provider applications for provider #{id}..."
        process(provider.bought_cinstances)

        logger.info "#{action} metrics for provider #{id}..."
        process(Metric.by_provider(provider))

        logger.info "#{action} usage limits for provider #{id}..."
        process(provider.usage_limits)
      end

      private

      # Rewrite the collection
      def process(collection)
        rewrite(scope: collection)
      end

      # This logger just prints out a message to STDOUT, with new line before and after.
      # New line before is to make progress log look better
      def logger
        @logger ||= begin
          log = ActiveSupport::Logger.new($stdout)
          log.formatter = ->(_, _, _, msg) { "\n#{msg.is_a?(String) ? msg : msg.inspect}\n" }
          log
        end
      end

      # All accounts eligible for backend sync
      # Optionally include inactive (deleted and suspended)
      def providers
        @providers ||=
          begin
            providers = Account.providers_with_master
            providers = providers.without_deleted.without_suspended unless include_inactive
            providers
          end
      end
    end

    # Used for scheduling asynchronous jobs for later processing
    class AsyncProcessor < Processor
      BATCH_SIZE = 500

      def initialize(**kwargs)
        super(**kwargs)
        @action = :enqueue
      end

      # Enqueue for asynchronous processing in batches
      def process(collection)
        collection.in_batches(of: BATCH_SIZE) do |batch|
          BackendStorageRewriteWorker.perform_async(batch.klass.name, batch.pluck(:id))
        end
      end
    end
  end
end
