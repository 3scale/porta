# frozen_string_literal: true

require 'test_helper'
require 'sidekiq/testing'

class Master::Api::Finance::Accounts::BillingJobsControllerTest < ActionDispatch::IntegrationTest
  include BillingResultsTestHelpers

  setup do
    @provider = FactoryBot.create(:provider_with_billing)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @access_token = FactoryBot.create(:access_token, owner: master_account.first_admin, scopes: ['account_management'])

    host! master_account.domain
  end

  test 'create billing job' do
    Finance::BillingService.expects(:async_call).with(@provider, Time.utc(2018,2,8), @provider.buyers.where(id: @buyer.id)).returns(true)
    post master_api_provider_account_billing_jobs_path(@provider, @buyer, date: '2018-02-08'), params: { access_token: @access_token.value }
    assert_response :accepted
  end

  test '#create schedules a worker' do
    assert_difference BillingWorker.jobs.method(:size) do
      post master_api_provider_account_billing_jobs_path(@provider, @buyer, date: '2018-02-08'), params: { access_token: @access_token.value }
      assert_response :accepted
    end
  end

  test 'create billing job with invalid account_id' do
    post master_api_provider_account_billing_jobs_path(@provider, account_id: 'invalid_account', date: '2018-02-08'), params: { access_token: @access_token.value }
    assert_response :not_found
  end

  test 'create billing job with account_id from different scope' do
    other_provider = FactoryBot.create(:provider_with_billing)
    other_buyer = FactoryBot.create(:buyer_account, provider_account: other_provider)
    post master_api_provider_account_billing_jobs_path(@provider, other_buyer, date: '2018-02-08'), params: { access_token: @access_token.value }
    assert_response :not_found
  end

  test 'create billing job without a date' do
    post master_api_provider_account_billing_jobs_path(@provider, @buyer), params: { access_token: @access_token.value }
    assert_response :bad_request
  end

  test 'create billing job with a time' do
    date = '2018-01-16 08:00:00 UTC'
    Sidekiq::Testing.inline! do
      billing_options = { only: [@provider.id], buyer_ids: [@buyer.id], now: Time.parse(date).to_date, skip_notifications: true }
      Finance::BillingStrategy.expects(:daily).with(billing_options).returns(mock_billing_success(date, @provider))
      post master_api_provider_account_billing_jobs_path(@provider, @buyer, date: date), params: { access_token: @access_token.value }
      assert_response :accepted
    end
  end

  test 'create billing job with a non-UTC date' do
    date = '2018-02-02 01:00:00 +09:00' # still 2018-02-01 UTC
    date_utc = Date.parse('2018-02-02')
    Sidekiq::Testing.inline! do
      billing_options = { only: [@provider.id], buyer_ids: [@buyer.id], now: date_utc, skip_notifications: true }
      Finance::BillingStrategy.expects(:daily).with(billing_options).returns(mock_billing_success(date_utc, @provider))
      post master_api_provider_account_billing_jobs_path(@provider, @buyer, date: date), params: { access_token: @access_token.value }
      assert_response :accepted
    end
  end

  test 'invalid date' do
    post master_api_provider_account_billing_jobs_path(@provider, @buyer, date: 'not a valid date'), params: { access_token: @access_token.value }
    assert_response :bad_request
  end

  class PermissionsTest < ActionDispatch::IntegrationTest
    disable_transactional_fixtures!

    setup do
      @provider = FactoryBot.create(:provider_with_billing)
      @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      @master_admin = master_account.first_admin
      host! master_account.domain
    end

    test 'scope account_management is required to create jobs' do
      unauthorized_token = FactoryBot.create(:access_token, owner: @master_admin, scopes: ['finance'])
      post master_api_provider_account_billing_jobs_path(@provider, @buyer, date: '2018-02-08'), params: { access_token: unauthorized_token.value }
      assert_response :forbidden

      authorized_token = FactoryBot.create(:access_token, owner: @master_admin, scopes: ['account_management'])
      post master_api_provider_account_billing_jobs_path(@provider, @buyer, date: '2018-02-08'), params: { access_token: authorized_token.value }
      assert_response :accepted
    end

    test 'members can create jobs with proper admin permission' do
      unauthorized_member = FactoryBot.create(:member, account: master_account, admin_sections: [])
      unauthorized_token = FactoryBot.create(:access_token, owner: unauthorized_member, scopes: ['account_management'])
      post master_api_provider_account_billing_jobs_path(@provider, @buyer, date: '2018-02-08'), params: { access_token: unauthorized_token.value }
      assert_response :forbidden

      authorized_member = FactoryBot.create(:member, account: master_account, admin_sections: [:partners])
      authorized_token = FactoryBot.create(:access_token, owner: authorized_member, scopes: ['account_management'])
      post master_api_provider_account_billing_jobs_path(@provider, @buyer, date: '2018-02-08'), params: { access_token: authorized_token.value }
      assert_response :accepted
    end

    test 'only rw access tokens can create jobs' do
      unauthorized_token = FactoryBot.create(:access_token, owner: @master_admin, scopes: ['account_management'], permission: 'ro')
      post master_api_provider_account_billing_jobs_path(@provider, @buyer, date: '2018-02-08'), params: { access_token: unauthorized_token.value }
      assert_response :forbidden

      authorized_token = FactoryBot.create(:access_token, owner: @master_admin, scopes: ['account_management'], permission: 'rw')
      post master_api_provider_account_billing_jobs_path(@provider, @buyer, date: '2018-02-08'), params: { access_token: authorized_token.value }
      assert_response :accepted
    end

    test "can't create jobs without an access token if logged in" do
      login! master_account, user: @master_admin
      post master_api_provider_account_billing_jobs_path(@provider, @buyer, date: '2018-02-08')
      assert_response :unauthorized
    end
  end
end
