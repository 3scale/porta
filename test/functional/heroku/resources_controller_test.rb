require 'test_helper'

class Heroku::ResourcesControllerTest < ActionController::TestCase
  include Heroku::ControllerMethods
  include TestHelpers::Heroku

  should route(:post, "http://#{master_account.domain}/heroku/resources").to action: 'create'
  should route(:put, "http://#{master_account.domain}/heroku/resources/42").to action: 'update', id: 42
  should route(:delete, "http://#{master_account.domain}/heroku/resources/42").to action: 'destroy', id: 42

  def setup
    @request.host = master_account.domain
    http_login
  end

  test 'post :create should create a user with account' do
    prepare_master_account
    assert_difference('Account.providers.count', 1) do
      raw_post :create, {}, heroku_params.to_json
    end
    assert_response 200

    user = assigns(:user)
    account = assigns(:account)
    assert_equal @partner, Account.find(account.id).partner

    assert user.pending?
    assert user.valid?
    assert user.account.valid?
    assert_equal account, user.account
    assert_equal "app4242.#{ThreeScale.config.superdomain}", account.domain
    assert_equal "app4242-admin.#{ThreeScale.config.superdomain}", account.self_domain
    assert_equal 'heroku-app4242', account.org_name
    assert_equal 'app4242@kensa.heroku.com', user.email
    assert_equal :'partner:heroku', user.signup_type
    assert account.default_service.present?
    assert account.settings.monthly_billing_enabled
    refute account.settings.monthly_charging_enabled
    assert_equal heroku_params[:heroku_id], account.settings.heroku_id

    assert_equal 'Customer', account.extra_fields['account_type']

    body = JSON.parse(response.body)
    assert_equal body['id'], user.id
    assert_equal body['config']['THREESCALE_PROVIDER_KEY'], account.api_key
  end

  test 'post: subdomain is taken' do
    prepare_master_account
    raw_post :create, {}, heroku_params.to_json
    assert_equal 'app4242', assigns(:account).subdomain
    raw_post :create, {}, heroku_params.to_json
    assert_equal 'app4242-1', assigns(:account).subdomain
    raw_post :create, {}, heroku_params.to_json
    assert_equal 'app4242-2', assigns(:account).subdomain
  end

  test 'post: with different plan' do
    prepare_master_account
    raw_post :create, {}, heroku_params.merge(plan: @partner.application_plans.last.system_name).to_json
    assert_equal assigns(:account).bought_cinstance.plan, @partner.application_plans.last
  end

  test 'put :update should change plan' do
    prepare_master_account
    raw_post :create, {}, heroku_params.to_json

    # upgrade
    raw_put :update, {id: assigns(:user).id}, heroku_params.merge(plan: @partner.application_plans.last.system_name).to_json
    assert_equal assigns(:account).bought_cinstance.plan, @partner.application_plans.last

    # downgrade
    raw_put :update, {id: assigns(:user).id}, heroku_params.merge(plan: @partner.application_plans.first.system_name).to_json
    assert_equal assigns(:account).bought_cinstance.plan, @partner.application_plans.first
  end

  test 'delete :destroy should destroy the account' do
    prepare_master_account
    raw_post :create, {}, heroku_params.to_json

    assert_difference('Account.providers.count', -1) do
      delete :destroy, id: assigns(:user).id
    end
  end
end
