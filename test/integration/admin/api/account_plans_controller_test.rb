# frozen_string_literal: true

require 'test_helper'

class Admin::Api::AccountPlansControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    @token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management]).value
    host! @provider.external_admin_domain
  end

  # This simple test is because rails 5.0 upgrade.
  # The issue was because the responder uses controller.stale?(resource)
  # https://github.com/3scale/porta/blob/bdc91b894eac16fbd81afd4f05198eb5cb8beee9/app/lib/three_scale/api/responder.rb#L11
  # Rails 5.0 `ActionController::Base#stale?` uses to_hash on the object and not Rails 4.x
  # But the +representable+ gem is extending each items with the representer inside the `to_hash`
  # https://github.com/trailblazer/representable/blob/v2.3.0/lib/representable/hash.rb#L32
  #
  # We implicitly extend those items with the JSON representer as to_json uses to_hash
  # So it works but might also breaks in the future ...
  def test_get
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
