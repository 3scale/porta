# frozen_string_literal: true

require 'test_helper'

class UsageLimitsTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'executing the task removes orphaned usage limits' do
    service = FactoryBot.create(:simple_service)
    service_metric = service.metrics.first
    plan = FactoryBot.create(:application_plan_without_rules, issuer: service)

    backend1 = FactoryBot.create(:backend_api, account: service.account)
    backend1_metric = FactoryBot.create(:metric, owner: backend1)
    backend1_usage_limit_id = FactoryBot.create(:usage_limit, metric: backend1_metric, plan: plan).id

    backend2 = FactoryBot.create(:backend_api, account: service.account)
    backend2_metric = FactoryBot.create(:metric, owner: backend2)
    backend2_usage_limit_id = FactoryBot.create(:usage_limit, metric: backend2_metric, plan: plan).id
    FactoryBot.create(:backend_api_config, service: service, backend_api: backend2)

    service_usage_limit_id = FactoryBot.create(:usage_limit, metric: service_metric, plan: plan).id

    assert_same_elements [backend1_usage_limit_id, backend2_usage_limit_id, service_usage_limit_id], plan.usage_limits.pluck(:id)

    execute_rake_task 'usage_limits.rake', 'usage_limits:clean_orphans'

    # usage limit that belongs to backend 1 should go away, because backend 1 is not linked to the service
    # other limits should stay, because they are valid
    assert_same_elements [backend2_usage_limit_id, service_usage_limit_id], plan.reload.usage_limits.pluck(:id)
  end
end
