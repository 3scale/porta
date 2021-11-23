# frozen_string_literal: true

require 'test_helper'

class ServicePresenterTest < ActiveSupport::TestCase
  test 'new application plan and service plans are sorted alphabetically' do
    service = FactoryBot.create(:simple_service)
    FactoryBot.create(:application_plan, issuer: service, position: 1, name: 'Application Plan 3')
    FactoryBot.create(:application_plan, issuer: service, position: 3, name: 'Application Plan 1')
    FactoryBot.create(:application_plan, issuer: service, position: 2, name: 'Application Plan 2')

    FactoryBot.create(:service_plan, issuer: service, position: 1, name: 'Service Plan 3')
    FactoryBot.create(:service_plan, issuer: service, position: 3, name: 'Service Plan 1')
    FactoryBot.create(:service_plan, issuer: service, position: 2, name: 'Service Plan 2')

    data = ServicePresenter.new(service).new_application_data

    app_plans = data[:appPlans]
    assert_equal (app_plans.sort_by { |p| p[:name] }), app_plans

    service_plans = data[:servicePlans]
    assert_equal (service_plans.sort_by { |p| p[:name] }), service_plans
  end
end
