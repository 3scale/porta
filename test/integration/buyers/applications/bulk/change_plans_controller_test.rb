# frozen_string_literal: true

require 'test_helper'

class Buyers::Applications::Bulk::ChangePlansControllerTest < ActionDispatch::IntegrationTest
  def setup
    @tenant = FactoryBot.create(:provider_account)
    login! tenant
  end

  attr_reader :tenant

  test '#new renders with the display_name in the title of the contract' do
    contracts = FactoryBot.create_list(:cinstance, 2, plan: FactoryBot.create(:application_plan, service: tenant.default_service))

    get new_admin_buyers_applications_bulk_change_plan_path, params: { selected: contracts.map(&:id) }

    page = Nokogiri::HTML::Document.parse(response.body)
    expected_display_names = contracts.map { |contract| contract.decorate.account_admin_user_display_name }
    li_title_display_names = page.xpath("//ul[@class='bulk_operation_items']/li").map { |li| li.attribute('title').value.split(' - ')[1] }
    assert_same_elements expected_display_names, li_title_display_names
  end
end
