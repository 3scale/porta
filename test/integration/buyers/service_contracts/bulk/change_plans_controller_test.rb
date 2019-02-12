# frozen_string_literal: true

require 'test_helper'

class Buyers::ServiceContracts::Bulk::ChangePlansControllerTest < ActionDispatch::IntegrationTest
  def setup
    tenant = FactoryBot.create(:provider_account)
    @service_contract = FactoryBot.create(:service_contract, plan: tenant.service_plans.first!)
    @change_service_plan = FactoryBot.create(:service_plan, issuer: tenant.default_service)
    login! tenant
  end

  attr_reader :service_contract, :change_service_plan

  test '#create renders errors correctly' do
    Contract.any_instance.stubs :save do
      errors.add(:base, 'any error')
      false
    end
    post admin_buyers_service_contracts_bulk_change_plan_path, selected: [service_contract.id], change_plans: {plan_id: change_service_plan.id}, action: 'create'
    assert_response :unprocessable_entity
    assert_template 'buyers/applications/bulk/shared/errors.html'
  end
end
