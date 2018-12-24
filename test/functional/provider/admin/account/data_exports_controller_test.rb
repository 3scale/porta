require 'test_helper'
require 'sidekiq/testing'


class Provider::Admin::Account::DataExportsControllerTest < ActionController::TestCase
  setup do
    @provider_account = FactoryBot.create :provider_account
    login_provider @provider_account
  end

  test 'for today' do
    post :create, :period => 'today', :data => 'messages'
    assert_response :redirect
  end

  test 'for this week' do
    post :create, :period => 'this_week', :data => 'messages'
    assert_response :redirect
  end

  test 'period not given' do
    post :create, :data => 'messages'
    assert_response :redirect
  end

  test 'with correct params enqueue sidekiq'  do
    DataExportsWorker.jobs.clear
    assert_difference 'DataExportsWorker.jobs.size' do
      post :create, data: 'applications', period: 'this_week'
    end
    DataExportsWorker.jobs.clear
  end


  test 'invalid params to export submitted redirect to new action on empty params' do
    post :create, :data => ''
    assert_redirected_to new_provider_admin_account_data_exports_path
  end

  test 'invalid params to export submitted redirect to new action on invalid params' do
    post :create, :data => 'invalid'
    assert_redirected_to new_provider_admin_account_data_exports_path
  end

  test 'invoices is present only if finance is allowed' do
    refute @provider_account.settings.finance.allowed?
    get :new
    assert_select 'select#data option[value="invoices"]', false

    @provider_account.settings.finance.allow
    assert @provider_account.settings.finance.allowed?
    get :new
    assert_select 'select#data option[value="invoices"]'
  end

end
