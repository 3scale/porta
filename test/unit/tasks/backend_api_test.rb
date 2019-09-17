require 'test_helper'

class Tasks::BackendApiTest < ActiveSupport::TestCase
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
