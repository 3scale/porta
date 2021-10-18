# frozen_string_literal: true

require 'test_helper'

class Buyers::ServiceContracts::Bulk::ChangePlansControllerTest < ActionDispatch::IntegrationTest
  def setup
    @tenant = FactoryBot.create(:provider_account)
    @service_contract = FactoryBot.create(:service_contract, plan: tenant.service_plans.first!)
    @change_service_plan = FactoryBot.create(:service_plan, issuer: tenant.default_service)
    login! tenant
  end

  attr_reader :service_contract, :change_service_plan, :tenant

  test '#create renders errors correctly' do
    Contract.any_instance.stubs :save do
      errors.add(:base, 'any error')
      false
    end
    post admin_buyers_service_contracts_bulk_change_plan_path, params: { selected: [service_contract.id], change_plans: {plan_id: change_service_plan.id}, action: 'create' }
    assert_response :unprocessable_entity
    assert_template 'buyers/applications/bulk/shared/errors.html'
  end

  test '#new renders with the display_name in the title of the contract' do
    another_service_contract = FactoryBot.create(:service_contract, plan: FactoryBot.create(:simple_service_plan, issuer: tenant.default_service))
    contracts = [service_contract, another_service_contract]

    tenant.settings.service_plans_ui_visible = true

    get new_admin_buyers_service_contracts_bulk_change_plan_path, params: { selected: contracts.map(&:id) }

    page = Nokogiri::HTML::Document.parse(response.body)

    expected_display_names = contracts.map { |contract| contract.decorate.account_admin_user_display_name }
    li_title_display_names = page.xpath("//ul[@class='bulk_operation_items']/li").map { |li| li.attribute('title').value.split(' - ')[1] }
    assert_same_elements expected_display_names, li_title_display_names
  end
end
