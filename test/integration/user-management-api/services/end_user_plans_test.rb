require 'test_helper'

class Admin::Api::Services::EndUserPlansTest < ActionDispatch::IntegrationTest

  def setup
    @account  = FactoryGirl.create(:provider_account)
    @service  = FactoryGirl.create(:simple_service, account: @account)
    @plan     = FactoryGirl.create(:end_user_plan, service: @service)

    host! @account.admin_domain
  end

  def test_crud_access_token
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    user  = FactoryGirl.create(:member, account: @account, admin_sections: ['partners'])
    token = FactoryGirl.create(:access_token, owner: user, scopes: 'account_management')

    # show
    params = access_token_params.merge(id: @plan.id)
    get(admin_api_service_end_user_plan_path(params))
    assert_response :forbidden
    params = access_token_params(token.value).merge(id: @plan.id)
    get(admin_api_service_end_user_plan_path(params))
    assert_response :not_found
    User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
    get(admin_api_service_end_user_plan_path(params))
    assert_response :success

    # create
    params = access_token_params(token.value).merge(plan_params)
    post(admin_api_service_end_user_plans_path(params))
    assert_response :success

    # update
    params = access_token_params(token.value).merge(id: @plan.id).merge(plan_params)
    put(admin_api_service_end_user_plan_path(params))
    assert_response :success

    # default
    params = access_token_params(token.value).merge(id: @plan.id)
    put(default_admin_api_service_end_user_plan_path(params))
    assert_response :success
  end

  def test_crud_provider_key
    # show
    Settings::Switch.any_instance.stubs(:allowed?).returns(false)
    params = provider_key_params.merge(id: @plan.id)
    get(admin_api_service_end_user_plan_path(params))
    assert_response :forbidden
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    get(admin_api_service_end_user_plan_path(params))
    assert_response :success

    # create
    params = provider_key_params.merge(plan_params)
    post(admin_api_service_end_user_plans_path(params))
    assert_response :success

    # update
    params = provider_key_params.merge(id: @plan.id).merge(plan_params)
    put(admin_api_service_end_user_plan_path(params))
    assert_response :success

    # default
    params = provider_key_params.merge(id: @plan.id)
    put(default_admin_api_service_end_user_plan_path(params))
    assert_response :success
  end

  private

  def plan_params
    {
      name: "Alaska_#{@service.end_user_plans.count + 1}"
    }
  end

  def access_token_params(token = '')
    default_params.merge({ access_token: token })
  end

  def provider_key_params
    default_params.merge({ provider_key: @account.provider_key })
  end

  def default_params
    { service_id: @service.id }
  end
end
