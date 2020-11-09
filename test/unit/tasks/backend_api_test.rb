require 'test_helper'

module Tasks
  class BackendApiTest < ActiveSupport::TestCase
    test 'create_default_metrics' do
      backend_apis_without_metrics = FactoryBot.create_list(:backend_api, 2)
      backend_apis_without_metrics.each { |backend_api| backend_api.metrics.delete_all }
      backend_apis_with_metrics = FactoryBot.create_list(:backend_api, 2)

      execute_rake_task 'backend_api.rake', 'backend_api:create_default_metrics'

      (backend_apis_without_metrics + backend_apis_with_metrics).each do |backend_api|
        assert_equal 1, backend_api.metrics.count
        assert_instance_of Metric, backend_api.metrics.top_level.hits
      end
    end
  end
end
