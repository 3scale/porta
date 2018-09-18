require 'test_helper'

class Buyers::AccountPlansControllerTest < ActionController::TestCase
  # we don't have show action
  #

  context 'provider account_plans switch' do
    setup do
      @provider = Factory :provider_account
      @request.host = @provider.domain

      login_as(@provider.admins.first)
    end

    context 'is denied' do
      setup do
        assert @provider.settings.account_plans_denied?
      end

      should 'forbid new' do
        get :new
        assert_equal 403, response.status
        assert_template 'errors/forbidden'
      end

      should 'forbid create' do
        post :create
        assert_equal 403, response.status
        assert_template 'errors/forbidden'
      end

      should 'render index' do
        get :index
        assert_equal 200, response.status
        assert_template 'api/plans/_default_plan'
      end
    end
  end

  context 'master account_plans switch' do
    setup do
      @master = master_account
      @request.host = @master.domain

      login_as(@master.admins.first)
    end

    context 'Not on-premises' do
      setup do
        ThreeScale.config.stubs(onpremises: false)
        assert @master.settings.account_plans_denied?
      end

      should 'forbid new' do
        get :new
        assert_equal 403, response.status
        assert_template 'errors/provider/forbidden'
      end

      should 'forbid create' do
        post :create
        assert_equal 403, response.status
        assert_template 'errors/provider/forbidden'
      end

      should 'render index' do
        get :index
        assert_equal 200, response.status
        assert_template 'api/plans/_default_plan'
      end
    end

    context 'On-premises' do
      setup do
        ThreeScale.config.stubs(onpremises: true)
        assert @master.settings.account_plans_denied?
      end

      should 'forbid new' do
        get :new
        assert_equal 403, response.status
        assert_template 'errors/provider/forbidden'
      end

      should 'forbid create' do
        post :create
        assert_equal 403, response.status
        assert_template 'errors/provider/forbidden'
      end

      should 'forbid index' do
        get :index
        assert_equal 403, response.status
        assert_template 'errors/provider/forbidden'
      end
    end
  end

  test 'destroy account plan, when account plan cant be destroyed, should not raise error' do
    @provider = Factory :provider_account
    @request.host = @provider.domain

    login_as(@provider.first_admin)
    AccountPlan.any_instance.expects(can_be_destroyed?: false).at_least_once
    delete :destroy, id: @provider.account_plans.first.id
  end
end
