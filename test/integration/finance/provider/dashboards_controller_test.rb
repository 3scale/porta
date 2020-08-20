# frozen_string_literal: true

require 'test_helper'

class Finance::Provider::DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    login! @provider
  end

  test 'raise exception if finance switch is denied' do
    assert @provider.settings.finance.denied?
    get admin_finance_root_path
    assert_response :forbidden
  end

  # TODO: add some fake invoices
  test 'show dashboard' do
    @provider.settings.allow_finance!
    get admin_finance_root_path
    assert_response :success
  end
end
