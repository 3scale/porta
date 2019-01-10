# frozen_string_literal: true

require 'test_helper'

class Admin::Api::AccountPlansControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    login! @provider
  end

  def test_create_valid_params_json
    assert_difference provider.account_plans.method(:count) do
      post admin_api_account_plans_path(account_plan_params)
      assert_response :success
      assert JSON.parse(response.body).dig('account_plan', 'id').present?
      assert_equal account_plan_params[:account_plan][:name], JSON.parse(response.body).dig('account_plan', 'name')
      assert_equal 'published', JSON.parse(response.body).dig('account_plan', 'state')
    end
  end

  def test_create_invalid_params_json
    assert_no_difference provider.account_plans.method(:count) do
      post admin_api_account_plans_path(account_plan_params('fakestate'))
      assert_response :unprocessable_entity
      assert_equal ['invalid'], JSON.parse(response.body).dig('errors', 'state_event')
    end
  end

  def test_update_valid_params_json
    account_plan = FactoryBot.create(:account_plan, name: 'firstname', state: 'hidden', provider: provider)
    put admin_api_account_plan_path(account_plan, account_plan_params)
    assert_response :success
    assert_equal account_plan_params[:account_plan][:name], account_plan.reload.name
    assert_equal 'published', account_plan.state
  end

  def test_update_invalid_params_json
    original_values = {name: 'firstname', state: 'hidden', provider: provider}
    account_plan = FactoryBot.create(:account_plan, original_values)
    put admin_api_account_plan_path(account_plan, account_plan_params('fakestate'))
    assert_response :unprocessable_entity
    assert_equal ['invalid'], JSON.parse(response.body).dig('errors', 'state_event')
    assert_equal original_values[:name], account_plan.reload.name
    assert_equal original_values[:state], account_plan.state
  end
  
  private
  
  attr_reader :provider

  def account_plan_params(state_event = 'publish')
    @account_plan_params ||= { account_plan: {name: 'testing', state_event: state_event}, format: :json }
  end
end
