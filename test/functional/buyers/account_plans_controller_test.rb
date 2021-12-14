# frozen_string_literal: true

require 'test_helper'

class Buyers::AccountPlansControllerTest < ActionController::TestCase
  # we don't have show action
  #

  class ProviderAccountPlansTest < Buyers::AccountPlansControllerTest
    def setup
      @provider = FactoryBot.create :provider_account
      @request.host = @provider.domain

      login_as(@provider.admins.first)

      assert @provider.settings.account_plans_denied?
    end

    test 'forbid new' do
      get :new
      assert_equal 403, response.status
      assert_template 'errors/forbidden'
    end

    test 'forbid create' do
      post :create
      assert_equal 403, response.status
      assert_template 'errors/forbidden'
    end

    test 'render index' do
      get :index
      assert_equal 200, response.status
      assert_template 'api/plans/_default_plan'
    end

    test 'destroy account plan, when account plan cant be destroyed, should not raise error' do
      AccountPlan.any_instance.expects(can_be_destroyed?: false).at_least_once
      delete :destroy, params: { id: @provider.account_plans.first.id }
    end
  end

  class MasterAccountPlansTest < Buyers::AccountPlansControllerTest
    def setup
      @master = master_account
      @request.host = @master.domain

      login_as(@master.admins.first)
    end

    class NotOnPremisesTest < MasterAccountPlansTest
      def setup
        super
        ThreeScale.config.stubs(onpremises: false)
        assert @master.settings.account_plans_denied?
      end

      test 'forbid new' do
        get :new
        assert_equal 403, response.status
        assert_template 'errors/provider/forbidden'
      end

      test 'forbid create' do
        post :create
        assert_equal 403, response.status
        assert_template 'errors/provider/forbidden'
      end

      test 'render index' do
        get :index
        assert_equal 200, response.status
        assert_template 'api/plans/_default_plan'
      end
    end

    class OnPremisesTest < MasterAccountPlansTest
      def setup
        super
        ThreeScale.config.stubs(onpremises: true)
        assert @master.settings.account_plans_denied?
      end

      test 'forbid new' do
        get :new
        assert_equal 403, response.status
        assert_template 'errors/provider/forbidden'
      end

      test 'forbid create' do
        post :create
        assert_equal 403, response.status
        assert_template 'errors/provider/forbidden'
      end

      test 'forbid index' do
        get :index
        assert_equal 403, response.status
        assert_template 'errors/provider/forbidden'
      end
    end
  end
end
