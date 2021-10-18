# frozen_string_literal: true

require 'test_helper'

class SignupExpressTest < ActionDispatch::IntegrationTest
  def setup
    @account_plan = FactoryBot.create(:account_plan, approval_required: true)
    @provider = @account_plan.provider
    host! @provider.admin_domain
  end

  test 'signup express with org name' do
    post '/admin/api/signup.xml', params: { provider_key: @provider.api_key, org_name: 'company', name: 'example', username: 'quentin', email: 'quentin@example.com', password: '12345678', account_plan_id: @account_plan.id }
    assert_response :success
    doc = Nokogiri::XML::Document.parse(@response.body)
    assert_equal 'company', doc.xpath('/account/org_name').text
  end

  test 'signup express with account plan that requires approval' do
    post '/admin/api/signup.xml', params: { provider_key: @provider.api_key, org_name: 'company', username: 'quentin', email: 'quentin@example.com', password: '12345678', account_plan_id: @account_plan.id }

    signup_result = assigns(:signup_result)
    assert signup_result.user.pending?
    assert signup_result.account.created?
    assert_equal @account_plan, signup_result.account.reload.bought_account_plan
  end

  test 'signup express with account plan that do not requires approval' do
    @account_plan.approval_required = false
    @account_plan.save!
    post '/admin/api/signup.xml', params: { provider_key: @provider.api_key, org_name: 'company', username: 'quentin', email: 'quentin@example.com', password: '12345678', account_plan_id: @account_plan.id }

    signup_result = assigns(:signup_result)
    assert signup_result.user_active?
    assert signup_result.account_approved?
    assert_equal @account_plan, signup_result.account.reload.bought_account_plan
  end

  test 'do not raise exception when validation fails for email duplications' do
    post '/admin/api/signup.xml', params: { provider_key: @provider.api_key, org_name: 'company', username: 'quentin', email: 'quentin@example.com', password: '12345678', account_plan_id: @account_plan.id }
    post '/admin/api/signup.xml', params: { provider_key: @provider.api_key, org_name: 'company', username: 'quentin', email: 'quentin@example.com', password: '12345678', account_plan_id: @account_plan.id }
  end

  test 'do not raise exception when account validations fails' do
    post '/admin/api/signup.xml', params: { provider_key: @provider.api_key, org_name: '', username: 'quentin', email: 'quentin@example.com', password: '12345678', account_plan_id: @account_plan.id }
  end
end
