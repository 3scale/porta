# frozen_string_literal: true

require 'test_helper'

module Backend
  class StorageRewriteTest < ActiveSupport::TestCase
    test 'rewrite provider resyncs all metrics of the provider' do
      provider = FactoryBot.create(:simple_provider)
      service = FactoryBot.create(:simple_service, account: provider)
      backend_api = FactoryBot.create(:backend_api, account: provider)
      service.backend_api_configs.create!(backend_api: backend_api, path: '/')
      [service.metrics.hits, backend_api.metrics.hits].each do |metric|
        ::BackendMetricWorker.expects(:perform_now).with(service.backend_id, metric.id)
      end
      StorageRewrite.rewrite_provider(provider.id)
    end
  end
end
