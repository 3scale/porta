# frozen_string_literal: true

require 'test_helper'

module Backend
  class StorageRewriteTest < ActiveSupport::TestCase

    class ProcessorRewriteTest < ActiveSupport::TestCase
      test 'calls correct rewriter for :class_name' do
        StorageRewrite::CinstanceRewriter.expects(:rewrite)
        StorageRewrite::Processor.new.rewrite(class_name: 'Cinstance')
      end

      test 'passes the class_name and ids to rewriter (used in async processing)' do
        ids = [1,2,3,4,5]
        StorageRewrite::MetricRewriter.expects(:rewrite).with({ ids: ids, log_progress: false })
        StorageRewrite::Processor.new.rewrite(class_name: 'Metric', ids: ids)
      end

      test 'passes the scope to rewriter (used in sync processing)' do
        provider = FactoryBot.create(:simple_provider)
        StorageRewrite::ServiceRewriter.expects(:rewrite).with({ scope: provider.services, log_progress: false })
        StorageRewrite::Processor.new.rewrite(scope: provider.services)
      end

      test 'raises an error when :scope or :class_name are not provided' do
        assert_raises(ArgumentError) { StorageRewrite::Processor.new.rewrite(ids: [1,2,3]) }
      end

      test 'enables log progress for rewriter if specified explicitly' do
        ids = [1,2,3,4,5]
        StorageRewrite::UsageLimitRewriter.expects(:rewrite).with({ ids: ids, log_progress: true })
        StorageRewrite::Processor.new(log_progress: true).rewrite(class_name: 'UsageLimit', ids: ids)
      end
    end

    class ProviderProcessingTest < ActiveSupport::TestCase
      attr_reader :providers

      setup do
        FactoryBot.create(:simple_master)
        @providers = FactoryBot.create_list(:simple_provider, 3)
        providers.last.schedule_for_deletion!
      end

      test 'run for master and all active providers by default' do
        processor = StorageRewrite::Processor.new
        # 2 active providers and 1 master
        processor.expects(:rewrite_provider).times(3)
        processor.rewrite_all
      end

      test 'run for master and inactive providers if specified explicitly' do
        processor = StorageRewrite::Processor.new(include_inactive: true)
        # 3 providers and 1 master
        processor.expects(:rewrite_provider).times(4)
        processor.rewrite_all
      end

      test 'rewrites all collections for a provider' do
        processor = StorageRewrite::Processor.new
        # services, provider's apps, buyers' apps, metrics and usage limits
        processor.expects(:rewrite).times(5)
        processor.rewrite_provider(providers.first.id)
      end

      test 'rewrite provider resyncs all metrics of the provider' do
        provider = providers.first
        service = FactoryBot.create(:simple_service, account: provider)
        backend_api = FactoryBot.create(:backend_api, account: provider)
        service.backend_api_configs.create!(backend_api: backend_api, path: '/')
        [service.metrics.hits, backend_api.metrics.hits].each do |metric|
          ::BackendMetricWorker.expects(:perform_now).with(service.backend_id, metric.id)
        end
        StorageRewrite::Processor.new.rewrite_provider(provider.id)
      end
    end

    class AsyncProcessorTest < ActiveSupport::TestCase
      test 'calls enqueuer for each collection batch' do
        # ensure all collections have items
        master = FactoryBot.create(:simple_master)
        provider = FactoryBot.create(:simple_provider)
        # Provider's app on master account
        provider_cinstance = FactoryBot.create(:simple_cinstance, plan: master.services.first.application_plans.first, user_account: provider)
        service = FactoryBot.create(:simple_service, account: provider)
        provider_app_plan = FactoryBot.create(:simple_application_plan, issuer: service)
        buyer = FactoryBot.create(:simple_buyer, provider_account: provider)
        # Buyer's app on provider account
        buyer_cinstance = FactoryBot.create(:simple_cinstance, plan: provider_app_plan, user_account: buyer)
        usage_limit = FactoryBot.create(:usage_limit, plan: provider_app_plan)

        BackendStorageRewriteWorker.expects(:perform_async).times(5).with do |klass, ids|
          ids.each do |id|
            assert_includes [service, provider_cinstance, buyer_cinstance, usage_limit, *service.metrics.to_a], Object.const_get(klass).find(id)
          end
        end
        Backend::StorageRewrite::AsyncProcessor.new.rewrite_provider(provider.id)
      end
    end
  end
end
