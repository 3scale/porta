# frozen_string_literal: true

require 'test_helper'
require 'sidekiq/testing'

class Provider::Admin::Account::DataExportsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    login! provider
  end

  attr_reader :provider

  test 'invoices is present only if finance is allowed' do
    refute provider.settings.finance.allowed?
    get new_provider_admin_account_data_exports_path
    assert_select 'select#data option[value="invoices"]', false

    provider.settings.finance.allow
    assert provider.settings.finance.allowed?
    get new_provider_admin_account_data_exports_path
    assert_select 'select#data option[value="invoices"]'
  end

  test 'for: today/this_week/period not given' do
    post provider_admin_account_data_exports_path, params: { period: 'today', data: 'messages' }
    assert_redirected_to new_provider_admin_account_data_exports_path

    post provider_admin_account_data_exports_path, params: { period: 'this_week', data: 'messages' }
    assert_redirected_to new_provider_admin_account_data_exports_path

    post provider_admin_account_data_exports_path, params: { data: 'messages' }
    assert_redirected_to new_provider_admin_account_data_exports_path
  end

  test 'invalid params to export submitted redirect to new action on empty/invalid params' do
    post provider_admin_account_data_exports_path, params: { data: '' }
    assert_redirected_to new_provider_admin_account_data_exports_path

    post provider_admin_account_data_exports_path, params: { data: 'invalid' }
    assert_redirected_to new_provider_admin_account_data_exports_path
  end

  test 'with correct params enqueue sidekiq'  do
    DataExportsWorker.jobs.clear
    assert_difference 'DataExportsWorker.jobs.size' do
      post provider_admin_account_data_exports_path, params: { period: 'this_week', data: 'applications' }
    end
    DataExportsWorker.jobs.clear
  end
end
