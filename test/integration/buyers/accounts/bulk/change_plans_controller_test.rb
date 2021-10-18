# frozen_string_literal: true

require 'test_helper'

class Buyers::Accounts::Bulk::ChangePlansControllerTest < ActionDispatch::IntegrationTest
  def setup
    tenant = FactoryBot.create(:provider_account)
    tenant.settings.account_plans.allow
    tenant.settings.update_column(:account_plans_ui_visible, true)
    login! tenant
    @buyer = FactoryBot.create(:buyer_account, provider_account: tenant)
  end

  attr_reader :buyer

  test '#new displays the buyer\'s admin_user_display_name' do
    get new_admin_buyers_accounts_bulk_change_plan_path, params: { selected: [buyer.id] }

    assert_xpath('//main//span', buyer.decorate.admin_user_display_name)
  end
end
