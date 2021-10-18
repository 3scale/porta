# frozen_string_literal: true

require 'test_helper'

class Admin::Api::BuyersApplicationsControllerTest < ActionDispatch::IntegrationTest

  def setup
    provider = FactoryBot.create(:provider_account)
    @service  = FactoryBot.create(:service, account: provider)
    @plan    = FactoryBot.create(:application_plan, service: @service)
    @buyer   = FactoryBot.create(:buyer_account, provider_account: provider)
    @token = FactoryBot.create(:access_token, owner: provider.admin_users.first!, scopes: %w[account_management]).value

    host! provider.admin_domain
  end

  def test_index
    get admin_api_account_applications_path(account_id: @buyer.id, format: :xml, access_token: @token)

    assert_response :success
  end

  def test_create
    post admin_api_account_applications_path(account_id: @buyer.id, plan_id: @plan.id, format: :xml, access_token: @token)

    assert_response :success
  end

  def test_delete
    application = FactoryBot.create(:cinstance, user_account: @buyer, service: @service)

    delete admin_api_account_application_path(account_id: @buyer.id, id: application.id, format: :xml, access_token: @token)

    assert_response :success
    assert_raises(ActiveRecord::RecordNotFound) { application.reload }
  end

  def test_create_raise_error
    params = {
      application_id: 'cba0c140',
      account_id:     @buyer.id,
      plan_id:        @plan.id,
      format:         :xml,
      access_token: @token
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

      @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      @plan = FactoryBot.create(:application_plan, service: @provider.default_service)
      @application = @buyer.buy! @plan
    end

    disable_transactional_fixtures!

    test 'change plan' do
      new_plan = create_new_plan_same_service
      request_plan_change new_plan
      assert_response :success
      assert_equal new_plan, @application.reload.plan
    end

    test 'cannot change plan to a different service' do
      service  = FactoryBot.create(:service, account: @provider)
      new_plan_other_service = FactoryBot.create(:application_plan, service: service)
      request_plan_change new_plan_other_service
      assert_response :unprocessable_entity
      assert_equal @plan, @application.reload.plan
    end

    test 'sends email to provider and buyer with new notification system' do
      Account.any_instance.stubs(provider_can_use?: true)

      Cinstances::CinstancePlanChangedEvent.expects(:create).with(@application, any_parameters).once
      ContractMessenger.expects(:plan_change).never

      ContractMessenger.expects(:plan_change_for_buyer).with(@application, any_parameters).once.returns(mock(deliver: true))

      request_plan_change
      assert_response :success
    end

    test 'sends email to provider and buyer with old notification system' do
      Account.any_instance.stubs(provider_can_use?: false)

      Cinstances::CinstancePlanChangedEvent.expects(:create).never
      ContractMessenger.expects(:plan_change).with(@application, any_parameters).once.returns(mock(deliver: true))

      ContractMessenger.expects(:plan_change_for_buyer).with(@application, any_parameters).once.returns(mock(deliver: true))

      request_plan_change
      assert_response :success
    end

    private

    def request_plan_change(new_plan = create_new_plan_same_service)
      params = { access_token: @access_token.value, plan_id: new_plan.id }
      put change_plan_admin_api_account_application_path(account_id: @buyer.id, id: @application.id, format: :xml), params: params
    end

    def create_new_plan_same_service
      FactoryBot.create(:application_plan, service: @provider.default_service)
    end
  end
end
