# frozen_string_literal: true

require 'progress_counter'

module Backend

  module StorageRewrite

    BATCH_SIZE = 1000

    # Base class for rewriters that sync objects to 3scale Backend.
    # Subclasses define CLASS, INCLUDE, and REWRITER constants.
    class Rewriter
      # @param scope [ActiveRecord::Associations::CollectionProxy] ActiveRecord collection with filtered scope
      # @param ids [Array] Array of IDs belonging to scope or class
      # @param log_progress [Boolean] specifies whether to print progress to console
      def self.rewrite(**kwargs)
        scope = kwargs[:scope] || self::CLASS
        ids = kwargs[:ids]
        scope = scope.where(id: ids) if ids.present?
        log_progress = kwargs[:log_progress] || false
        progress = log_progress ? ProgressCounter.new(scope.count) : nil

        iterate(scope.includes(self::INCLUDE), progress)
      end

      def self.iterate(scope, progress)
        scope.find_each do |model|
          self::REWRITER.call(model)
          progress&.call
        end
      end
      private_class_method :iterate
    end

    class BatchRewriter < Rewriter
      def self.iterate(scope, progress)
        scope.find_in_batches(batch_size: StorageRewrite::BATCH_SIZE) do |batch|
          self::REWRITER.call(batch)
          progress&.call(increment: batch.size)
        end
      end
      private_class_method :iterate
    end

    class CinstanceRewriter < BatchRewriter
      CLASS = Cinstance
      INCLUDE = %i[plan service application_keys referrer_filters].freeze
      # All records in a batch must belong to the same service. Callers are responsible
      # for scoping per service before passing the collection (see Processor#rewrite_provider).
      REWRITER = ->(batch) do
        service = batch.first.service
        return unless service

        expected_service_id = batch.first.service_id
        applications = batch.filter_map do |cinstance|
          if cinstance.service_id != expected_service_id
            Rails.logger.error(
              "[StorageRewrite] Batch spans multiple services; expected service_id #{expected_service_id} " \
              "but found #{cinstance.service_id}. Skipping batch."
            )
            return # rubocop:disable Lint/NonLocalExitFromIterator
          end

          plan = cinstance.plan
          next unless plan

          cinstance.backend_batch_attributes(service, plan)
        end

        if applications.present?
          result = ThreeScale::Core::Application.save_batch(service.backend_id, applications)
          if result && result[:failed].to_i.positive?
            failed_ids = result[:failures]&.map { _1[:id] }&.join(', ') # rubocop:disable Rails/Pluck
            Rails.logger.error(
              "[StorageRewrite] Batch save partial failure for service #{service.backend_id}: " \
              "#{result[:failed]} failed (#{failed_ids})"
            )
          end
        end
      end
    end

    class ServiceRewriter < Rewriter
      CLASS = Service
      INCLUDE = :account
      REWRITER = ->(service) do
        service.update_backend_service
        service.service_tokens.find_each(&ServiceTokenService.method(:update_backend))
        service.send(:update_notification_settings)
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
        rewriter.rewrite(**kwargs, log_progress: log_progress)
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

        services = provider.services
        logger.info "#{action} services for provider #{id}..."
        process(services)

        logger.info "#{action} applications for provider #{id}..."
        services.each do |service|
          process(provider.buyer_applications.where(service: service))
        end

        logger.info "#{action} provider applications for provider #{id}..."
        # A provider is almost always subscribed to only one master service, but iterate
        # per-service for correctness since CinstanceRewriter assumes a single-service batch.
        master_services = Service.where(account: Account.master)
        master_services.each do |service|
          process(provider.bought_cinstances.where(service: service))
        end

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

      def logger
        @logger ||= ProgressCounter.stdout_logger
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
      def initialize(**kwargs)
        super(**kwargs)
        @action = :enqueue
      end

      # Enqueue for asynchronous processing in batches
      def process(collection)
        collection.in_batches(of: StorageRewrite::BATCH_SIZE) do |batch|
          BackendStorageRewriteWorker.perform_async(batch.klass.name, batch.pluck(:id))
        end
      end
    end
  end
end
