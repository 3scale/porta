require 'test_helper'

class Admin::Api::BuyersApplicationsControllerTest < ActionDispatch::IntegrationTest

  def setup
    provider = FactoryBot.create(:provider_account)
    @service  = FactoryBot.create(:service, account: provider)
    @plan    = FactoryBot.create(:application_plan, service: @service)
    @buyer   = FactoryBot.create(:buyer_account, provider_account: provider)

    host! provider.admin_domain

    login_provider provider
  end

  def test_index
    get admin_api_account_applications_path(account_id: @buyer.id, format: :xml)

    assert_response :success
  end

  def test_create
    post admin_api_account_applications_path(account_id: @buyer.id, plan_id: @plan.id, format: :xml)

    assert_response :success
  end

  def test_delete
    application = FactoryBot.create(:cinstance, user_account: @buyer, service: @service)

    delete admin_api_account_application_path(account_id: @buyer.id, id: application.id, format: :xml)

    assert_response :success
    assert_raises(ActiveRecord::RecordNotFound) { application.reload }
  end

  def test_create_raise_error
    params = {
      application_id: 'cba0c140',
      account_id:     @buyer.id,
      plan_id:        @plan.id,
      format:         :xml
    }

    post admin_api_account_applications_path(params)

    assert_response :success

    # second time responds with errors instead of raising
    post admin_api_account_applications_path(params)

    assert_response :unprocessable_entity
  end

  class ChangePlanTest < ActionDispatch::IntegrationTest
    setup do
      @provider = FactoryBot.create(:provider_account)
      @access_token = FactoryBot.create(:access_token, owner: @provider.admin_user, scopes: 'account_management')

      host! @provider.admin_domain

      @account = FactoryBot.create(:buyer_account, provider_account: @provider)
      @plan = FactoryBot.create(:application_plan, service: @provider.default_service)
      @application = @account.buy! @plan
    end

    test 'change plan' do
      new_plan = FactoryBot.create(:application_plan, service: @provider.default_service)

      params = { access_token: @access_token.value, plan_id: new_plan.id }
      put change_plan_admin_api_account_application_path(account_id: @account.id, id: @application.id, format: :xml), params

      assert_response :success
      assert_equal new_plan, @application.reload.plan
    end

    test 'cannot change plan to a different service' do
      service  = FactoryBot.create(:service, account: @provider)
      new_plan = FactoryBot.create(:application_plan, service: service)

      params = { access_token: @access_token.value, plan_id: new_plan.id }
      put change_plan_admin_api_account_application_path(account_id: @account.id, id: @application.id, format: :xml), params

      assert_response :precondition_failed
      assert_equal @plan, @application.reload.plan
    end
  end
end
