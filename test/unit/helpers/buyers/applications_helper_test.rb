require 'test_helper'

class Buyers::ApplicationsHelperTest < ActionView::TestCase

  test "services_contracted should return a json array of service ids" do
    buyer = FactoryBot.create(:buyer_account)
    service_ids = []
    service_ids << FactoryBot.create(:service_contract, user_account: buyer).service.id
    service_ids << FactoryBot.create(:service_contract, user_account: buyer).service.id
    assert_same_elements service_ids, JSON.parse(services_contracted(buyer))
  end

  test "services_contracted should return a empty array" do
    buyer = FactoryBot.create(:buyer_account)
    assert_equal services_contracted(buyer), [].to_json
  end

  test "service_plan_contracted_for_service" do
    buyer = FactoryBot.create(:buyer_account)
    service_contract = FactoryBot.create(:service_contract, user_account: buyer)
    buyer.reload

    service_plan = buyer.bought_service_plans[0]

    hash = {}
    hash[service_plan.service.id] = {id: service_plan.id, name: service_plan.name}

    assert_equal service_plan_contracted_for_service(buyer), hash.to_json
  end

  test "service_plan_contracted_for_service should return a empty hash" do
    assert_equal service_plan_contracted_for_service(Account.providers.new), {}.to_json
  end

  # DELETEME: APPDUX-762
  test "relation_service_and_service_plans" do
    provider = FactoryBot.create(:provider_account)

    service = provider.services[0]
    service_plan = service.service_plans[0]

    hash = {}
    hash[service.id] = [{id: service_plan.id, name: service_plan.name, default: false}]

    assert_equal relation_service_and_service_plans(provider), hash.to_json
  end

  test "relation_service_and_service_plans should return a empty hash" do
    assert_equal relation_service_and_service_plans(Account.providers.new), {}.to_json
  end

  test "relation_plans_services" do
    application_plan = FactoryBot.create(:application_plan)
    service = application_plan.service
    provided_plan = service.provided_plans[0]
    provider = provided_plan.provider_account

    hash = {}
    hash[application_plan.id] = service.id
    assert_equal relation_plans_services(provider), hash.to_json
  end

  test "relation_plans_services should return a empty hash" do
    assert_equal relation_plans_services(Account.providers.new), {}.to_json
  end

  test "remaining_trial_days should return the right expiration date text" do
    time = Time.utc(2015, 1,20, 10, 10, 10)
    cinstance = FactoryBot.build(:cinstance, trial_period_expires_at: time)
    expected_date = '&ndash; trial expires in <time datetime="2015-01-20T10:10:10Z" title="20 Jan 2015 10:10:10 UTC">20 days</time>'

    Timecop.freeze(time - 20.days) do
      assert_equal expected_date, remaining_trial_days(cinstance)
    end
  end
end
