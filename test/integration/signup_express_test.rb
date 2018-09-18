require 'test_helper'

class SignupExpressTest < ActionDispatch::IntegrationTest

  disable_transactional_fixtures!

  test 'signup express with account plan that requires approval' do
    @account_plan = FactoryGirl.create(:account_plan, approval_required: true)
    @provider = @account_plan.provider
    host! @provider.admin_domain

    post '/admin/api/signup.xml', provider_key: @provider.api_key, org_name: 'company', username: 'quentin', email: 'quentin@example.com', password: '12345678', account_plan_id: @account_plan.id

    signup_result = assigns(:signup_result)
    assert signup_result.user.pending?
    assert signup_result.account.created?
    assert_equal @account_plan, signup_result.account.reload.bought_account_plan
  end

  test 'signup express with account plan that do not requires approval' do
    @account_plan = FactoryGirl.create(:account_plan, approval_required: false)
    @provider = @account_plan.provider
    host! @provider.admin_domain

    post '/admin/api/signup.xml', provider_key: @provider.api_key, org_name: 'company', username: 'quentin', email: 'quentin@example.com', password: '12345678', account_plan_id: @account_plan.id

    signup_result = assigns(:signup_result)
    assert signup_result.user_active?
    assert signup_result.account_approved?
    assert_equal @account_plan, signup_result.account.reload.bought_account_plan
  end

  test 'do not raise exception when validation fails for email duplications' do
    @account_plan = FactoryGirl.create(:account_plan, approval_required: false)
    @provider = @account_plan.provider
    host! @provider.admin_domain

    post '/admin/api/signup.xml', provider_key: @provider.api_key, org_name: 'company', username: 'quentin', email: 'quentin@example.com', password: '12345678', account_plan_id: @account_plan.id


    post '/admin/api/signup.xml', provider_key: @provider.api_key, org_name: 'company', username: 'quentin', email: 'quentin@example.com', password: '12345678', account_plan_id: @account_plan.id

  end

  test 'do not raise exception when account validations fails' do
    @account_plan = FactoryGirl.create(:account_plan, approval_required: false)
    @provider = @account_plan.provider
    host! @provider.admin_domain

    post '/admin/api/signup.xml', provider_key: @provider.api_key, org_name: '', username: 'quentin', email: 'quentin@example.com', password: '12345678', account_plan_id: @account_plan.id

  end


end
