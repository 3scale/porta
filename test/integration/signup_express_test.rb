# frozen_string_literal: true

require 'test_helper'

class SignupExpressTest < ActionDispatch::IntegrationTest
  def setup
    @account_plan = FactoryBot.create(:account_plan, approval_required: true)
    @provider = @account_plan.provider
    host! @provider.external_admin_domain
  end

  test 'signup express with org name' do
    org_name = 'My Company'
    post admin_api_signup_path(format: :xml), params: params(org_name: org_name)
    assert_response :success
    doc = Nokogiri::XML::Document.parse(@response.body)
    assert_equal org_name, doc.xpath('/account/org_name').text
  end

  test 'signup express with account plan that requires approval' do
    post admin_api_signup_path(format: :xml), params: params

    signup_result = assigns(:signup_result)
    assert signup_result.user.pending?
    assert signup_result.account.created?
    assert_equal @account_plan, signup_result.account.reload.bought_account_plan
  end

  test 'signup express with account plan that do not requires approval' do
    @account_plan.approval_required = false
    @account_plan.save!
    post admin_api_signup_path(format: :xml), params: params

    signup_result = assigns(:signup_result)
    assert signup_result.user_active?
    assert signup_result.account_approved?
    assert_equal @account_plan, signup_result.account.reload.bought_account_plan
  end

  test 'do not raise exception when validation fails for email duplications' do
    post admin_api_signup_path(format: :xml), params: params
    assert_response :success
    post admin_api_signup_path(format: :xml), params: params
    assert_response 422
  end

  test 'do not raise exception when account validations fails' do
    post admin_api_signup_path(format: :xml), params: params(org_name: '')
    assert_response 422
  end

  private

  def params(custom_params = {})
    {
      provider_key: @provider.api_key,
      name: 'example',
      org_name: 'company',
      username: 'quentin',
      email: 'quentin@example.com',
      password: 'superSecret1234#',
      account_plan_id: @account_plan.id
    }.merge(custom_params)
  end
end
