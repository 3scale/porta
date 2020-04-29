require 'test_helper'

module Tasks
  class BackendApiTest < ActiveSupport::TestCase
    class DestroyOrphans < ActiveSupport::TestCase
      setup do
        @backend_api = FactoryBot.create(:backend_api)
        FactoryBot.create(:backend_api_config, backend_api: @backend_api)
        @orphan_backend_api = FactoryBot.create(:backend_api)
      end

      test 'destroy orphans when account can not use api as product' do
        Account.any_instance.stubs(:provider_can_use?).with(:api_as_product).returns(false).at_least_once
        DeleteObjectHierarchyWorker.expects(:perform_later).with(@orphan_backend_api).once
        DeleteObjectHierarchyWorker.expects(:perform_later).with(@backend_api).never

        execute_rake_task 'backend_api.rake', 'backend_api:destroy_orphans'
      end

      test 'does not destroy orphans when account can use api as product' do
        Account.any_instance.stubs(:provider_can_use?).with(:api_as_product).returns(true).at_least_once
        DeleteObjectHierarchyWorker.expects(:perform_later).with(@orphan_backend_api).never
        DeleteObjectHierarchyWorker.expects(:perform_later).with(@backend_api).never

        execute_rake_task 'backend_api.rake', 'backend_api:destroy_orphans'
      end
    end

    test 'create_default_metrics' do
      backend_apis_without_metrics = FactoryBot.create_list(:backend_api, 2)
      backend_apis_without_metrics.each { |backend_api| backend_api.metrics.delete_all }
      _backend_apis_with_metrics = FactoryBot.create_list(:backend_api, 2)

      execute_rake_task 'backend_api.rake', 'backend_api:create_default_metrics'

      BackendApi.all.each do |backend_api|
        assert_equal 1, backend_api.metrics.count
        assert_instance_of Metric, backend_api.metrics.top_level.hits
      end
    end
  end
end
