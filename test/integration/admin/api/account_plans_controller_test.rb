# frozen_string_literal: true

require 'test_helper'

class Admin::Api::AccountPlansControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    @token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management]).value
    host! @provider.external_admin_domain
  end

  # Originally, this test was added in https://github.com/3scale/porta/commit/379b3dc26189f7dc5c5276de84d70c46ba5ae0b6
  # and tested that calling #stale? in the controller was not affecting the XML representation of the object -
  # as after upgrading from rails 4.x to rails 5.0, #stale? started calling #to_hash, breaking the response.
  # As of today (Rails 7.1) .to_hash is not called by ActionController anymore, so the test was just kept to prevent
  # potential future regressions
  # This test demonstrates that +representable+ gem that we use for object representers (to convert objects to XML/JSON)
  # mutates the caller objects on `.to_hash`.
  # Specifically, in this test for the Plan object, the `trial_period_days` attribute with nil value is represented as:
  # - `<trial_period_days>0</trial_period_days>` if `.to_hash` is called before `.to_xml`
  # - `<trial_period_days/>` if just `.to_xml` is called
  # Calling `.to_hash` before `.to_json` doesn't have any effect, because `.to_json` calls `.to_hash` anyway.
  def test_account_plan_representer
    account_plans = @provider.account_plans.to_a
    represented = AccountPlansRepresenter.prepare(account_plans)

    # Uncommenting this will break the test :)
    # represented.to_hash

    xml = represented.to_xml
    get admin_api_account_plans_path(format: :xml, access_token: @token)

    assert_response :success
    assert_equal xml, response.body

    represented.to_hash
    json = represented.to_json
    get admin_api_account_plans_path(format: :json, access_token: @token)
    assert_response :success
    assert_equal json, response.body
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
      post admin_api_account_plans_path(account_plan_params(state_event: 'fakestate'))
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
    put admin_api_account_plan_path(account_plan, account_plan_params(state_event: 'fakestate'))
    assert_response :unprocessable_entity
    assert_equal ['invalid'], JSON.parse(response.body).dig('errors', 'state_event')
    assert_equal original_values[:name], account_plan.reload.name
    assert_equal original_values[:state], account_plan.state
  end

  def test_approval_required
    assert_difference provider.account_plans.method(:count) do
      post admin_api_account_plans_path(account_plan_params(approval_required: true))
      assert_response :success
      assert JSON.parse(response.body).dig('account_plan', 'id').present?
    end
    account_plan = provider.account_plans.last
    assert account_plan.approval_required
  end

  private

  attr_reader :provider

  def account_plan_params(state_event: 'publish', approval_required: 0)
    @account_plan_params ||= { account_plan: { name: 'testing', state_event: state_event, approval_required: approval_required }, format: :json, access_token: @token,}
  end
end
