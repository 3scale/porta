# frozen_string_literal: true

require 'test_helper'

class Api::ApplicationPlansControllerTest < ActionController::TestCase

  class ProviderAccountLoggedInTest < Api::ApplicationPlansControllerTest
    def setup
      @provider = FactoryGirl.create(:provider_account)
      @service  = FactoryGirl.create(:service, account: @provider)
      @plan     = FactoryGirl.create(:application_plan, service: @service)

      host! @provider.admin_domain

      login_provider @provider
    end

    def test_index
      get :index, service_id: @service.id
      assert_response :success
      assert_template 'api/application_plans/index'
    end

    def test_new
      get :new, service_id: @service.id
      assert_response :success
      assert_template 'api/application_plans/new'
    end

    def test_create
      assert_difference @service.application_plans.method(:count) do
        post :create, application_plan_params
        assert_response :redirect
        assert_equal 'Created Application plan testing', flash[:notice]
      end
    end

    def test_destroy
      delete :destroy, id: @plan.id

      assert_response :redirect
      assert_nil flash[:error]
    end

    def test_plan_cannot_be_deleted
      @plan.create_contract_with(FactoryGirl.create(:buyer_account))

      delete :destroy, id: @plan.id

      assert_response :redirect
      assert_equal error_message(:has_contracts), flash[:error]
    end

    def test_plan_cannot_be_deleted_because_of_customizations
      customization = FactoryGirl.create(:application_plan, original_id: @plan.id)
      customization.create_contract_with(FactoryGirl.create(:buyer_account))

      delete :destroy, id: @plan.id

      assert_response :redirect
      assert_equal error_message(:customizations_has_contracts), flash[:error]
    end

    private

    def error_message(key)
      I18n.t("activerecord.errors.models.application_plan.#{key}")
    end
  end

  class MasterAccountLoggedInTest < Api::ApplicationPlansControllerTest
    def setup
      @service = master_account.first_service!
      login_provider master_account
    end

    def test_index_saas
      get :index, service_id: @service.id
      assert_response :success
      assert_template 'api/application_plans/index'
    end

    def test_index_on_premises
      ThreeScale.stubs(master_on_premises?: true)
      get :index, service_id: @service.id
      assert_response :forbidden
      assert_template 'errors/provider/forbidden'
    end

    def test_new_saas
      get :new, service_id: @service.id
      assert_response :success
      assert_template 'api/application_plans/new'
    end

    def test_new_on_premises
      ThreeScale.stubs(master_on_premises?: true)
      get :new, service_id: @service.id
      assert_response :forbidden
      assert_template 'errors/provider/forbidden'
    end

    def test_create_saas
      assert_difference @service.application_plans.method(:count) do
        post :create, application_plan_params
        assert_response :redirect
        assert_equal 'Created Application plan testing', flash[:notice]
      end
    end

    def test_create_on_premises
      ThreeScale.stubs(master_on_premises?: true)
      assert_no_difference @service.application_plans.method(:count) do
        post :create, application_plan_params
        assert_response :forbidden
        assert_template 'errors/provider/forbidden'
      end
    end

    def test_destroy_saas
      plan = FactoryGirl.create(:application_plan, service: @service)
      assert_difference( @service.application_plans.method(:count), -1 ) do
        delete :destroy, id: plan.id
        assert_response :redirect
        assert_equal 'The plan was deleted', flash[:notice]
      end
      assert_raise ActiveRecord::RecordNotFound do
        plan.reload
      end
    end

    def test_destroy_on_premises
      ThreeScale.stubs(master_on_premises?: true)
      plan = FactoryGirl.create(:application_plan, service: @service)
      assert_no_difference @service.application_plans.method(:count) do
        delete :destroy, id: plan.id
        assert_response :forbidden
        assert_template 'errors/provider/forbidden'
        assert plan.reload
      end
    end
  end

  def application_plan_params
    { service_id: @service.id, application_plan: { name: 'testing', system_name: 'testing', approval_required: 0 } }
  end
end
