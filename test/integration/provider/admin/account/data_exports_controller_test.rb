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
    assert_not provider.settings.finance.allowed?
    get new_provider_admin_account_data_exports_path
    assert_select 'select#export_data option[value="invoices"]', false

    provider.settings.finance.allow
    assert provider.settings.finance.allowed?
    get new_provider_admin_account_data_exports_path
    assert_select 'select#export_data option[value="invoices"]'
  end

  test 'for: today/this_week/all periods' do
    post provider_admin_account_data_exports_path, params: { export: { period: 'today', data: 'messages' } },
                                                   xhr: true
    assert_response :success

    post provider_admin_account_data_exports_path, params: { export: { period: 'this_week', data: 'messages' } },
                                                   xhr: true
    assert_response :success

    post provider_admin_account_data_exports_path, params: { export: { period: 'all', data: 'messages' } },
                                                   xhr: true
    assert_response :success
  end

  test 'invalid data params show error message' do
    post provider_admin_account_data_exports_path, params: { export: { data: 'invalid', period: 'today' } },
                                                   xhr: true
    assert_response :success
    assert_equal flash[:danger], "Requested data can't be exported."
  end

  test 'invalid period params show error message' do
    post provider_admin_account_data_exports_path, params: { export: { data: 'messages', period: 'invalid' } },
                                                   xhr: true
    assert_response :success
    assert_equal flash[:danger], "Can't export data for the selected period."
  end

  test 'with correct params enqueue sidekiq and show success message'  do
    DataExportsWorker.jobs.clear
    assert_difference 'DataExportsWorker.jobs.size' do
      post provider_admin_account_data_exports_path, params: { export: { period: 'this_week', data: 'applications' } },
                                                     xhr: true
    end
    assert_response :success
    assert_equal flash[:success], "Report will be mailed to #{provider.first_admin.email}."
    DataExportsWorker.jobs.clear
  end

  test "members can't access export page" do
    member = FactoryBot.create(:member, account: @provider)
    member.activate!
    login!(@provider, user: member)

    get new_provider_admin_account_data_exports_path
    assert_response :forbidden
  end
end
