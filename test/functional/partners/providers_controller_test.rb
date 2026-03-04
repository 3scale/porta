# frozen_string_literal: true

require 'test_helper'

class Partners::ProvidersControllerTest < ActionController::TestCase
  def setup
    host! master_account.external_domain
    @partner = FactoryBot.create(:partner, system_name: 'someone')
  end

  def prepare_master_account
    service = master_account.default_service
    %w{blibli bloblo blabla}.each do |key|
      service.application_plans.create!(name: key, system_name: key, partner: @partner)
    end

    master_account.account_plans.default!(master_account.account_plans.first)
    master_account.default_service.service_plans.default!(master_account.service_plans.first)
  end

  def provider_params
    {subdomain: 'troloro', org_name: 'foo-org', email: 'foo@example.net', first_name: 'Tyler', last_name: 'Durden', api_key: @partner.api_key, open_id: "openid"}
  end

  test 'routes' do
    assert_routing({ method: 'post', path: "http://#{master_account.external_domain}/partners/providers" }, { action: 'create', format: 'json', controller: 'partners/providers' })
  end

  test 'required api_key' do
    post :create
    assert_response :unauthorized
    assert_equal 'unauthorized', response.body
  end

  test 'post create should create a user with account' do
    prepare_master_account
    ThreeScale::Analytics::UserTracking.any_instance.expects(:track).once.with('Activated account', {})

    ThreeScale::Analytics::UserTracking.any_instance.expects(:track).once.with('Signup', {})

    assert_difference('Account.providers.count', 1) do
      post :create, params: provider_params
    end

    assert_response 200
    user = assigns(:user)
    account = assigns(:account)

    assert user.active?
    assert user.valid?
    assert user.account.valid?
    assert_equal :'partner:someone', user.signup_type
    assert_equal account, user.account

    assert_equal provider_params[:open_id], user.open_id
    assert_equal provider_params[:first_name], user.first_name
    assert_equal provider_params[:last_name], user.last_name
    assert_equal provider_params[:email], user.email

    assert_equal "troloro-#{@partner.system_name}.#{ThreeScale.config.superdomain}", account.internal_domain
    assert_equal "troloro-#{@partner.system_name}-admin.#{ThreeScale.config.superdomain}", account.internal_admin_domain
    assert_equal "#{@partner.system_name}-#{provider_params[:org_name]}", account.org_name
    assert_equal @partner.application_plans.first, account.bought_cinstance.plan
    assert_equal @partner.system_name, account.extra_fields['partner']

    assert_equal @partner, Account.find(account.id).partner
    assert account.default_service.present?
    assert account.settings.monthly_billing_enabled
    refute account.settings.monthly_charging_enabled

    body = JSON.parse(response.body)
    assert_equal body['id'], account.id
    assert_equal body['provider_key'], account.api_key
    assert_equal body['end_point'], account.internal_admin_domain
    assert_equal body['success'], true
  end

  test 'post with specific password' do
    prepare_master_account
    post :create, params: provider_params.merge(password: 'superSecret1234#')
    user = assigns(:user)
    account = assigns(:account)
    strategy = Authentication::Strategy::Internal.new(account, true)
    assert strategy.authenticate(username: user.username, password: 'superSecret1234#')
    body = JSON.parse(response.body)
    assert_equal body['success'], true
  end

  test 'post without password creates user with no password' do
    prepare_master_account
    post :create, params: provider_params

    assert_response :success
    user = assigns(:user)
    assert user.valid?
    assert_nil user.password_digest, 'User should have no password when not provided'
    assert_not user.already_using_password?, 'User should not be using password'

    body = JSON.parse(response.body)
    assert_equal true, body['success']
  end

  test 'post with weak password rejected when strong passwords enabled' do
    prepare_master_account

    post :create, params: provider_params.merge(password: 'weakpwd')

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)

    refute body['success']
    assert body['errors']['user']['password'].present?
  end

  test 'post with strong password accepted when strong passwords enabled' do
    prepare_master_account

    post :create, params: provider_params.merge(password: 'superSecret1234#')

    assert_response :success
    user = assigns(:user)
    assert user.valid?
    assert user.authenticated?('superSecret1234#')

    body = JSON.parse(response.body)
    assert_equal true, body['success']
  end

  test 'post with an invalid email' do
    prepare_master_account
    post :create, params: provider_params.merge(email: 'invalid')
    body = JSON.parse(response.body)
    refute body["success"]
    assert body["errors"]["user"]["email"].present?
    assert_equal "422", response.code
  end

  test 'post with a existing subdomain' do
    prepare_master_account
    FactoryBot.create(:simple_provider, provider_account: master_account, subdomain: "taken-#{@partner.system_name}", partner: @partner)
    post :create, params: provider_params.merge(subdomain: 'taken')

    body = JSON.parse(response.body)
    refute body["success"]
    assert body["errors"]["account"]["subdomain"].present?
    assert_equal "422", response.code
  end

  test 'post with different plan' do
    prepare_master_account
    post :create, params: provider_params.merge(application_plan: @partner.application_plans.last.system_name)
    assert_equal assigns(:account).bought_cinstance.plan, @partner.application_plans.last
    body = JSON.parse(response.body)
    assert_equal body['success'], true
  end

  test 'put update should change plan' do
    prepare_master_account
    account = FactoryBot.create(:provider_account, subdomain: 'troloro', org_name: 'foo-org', provider_account: master_account, partner: @partner)

    # upgrade
    put :update, params: { id: account.id, application_plan: @partner.application_plans.last.system_name, api_key: @partner.api_key }
    assert_equal account.reload.bought_cinstance.plan, @partner.application_plans.last
    body = JSON.parse(response.body)
    assert_equal body['success'], true

    # downgrade
    put :update, params: { id: account.id, application_plan: @partner.application_plans.first.system_name, api_key: @partner.api_key }
    assert_equal account.reload.bought_cinstance.plan, @partner.application_plans.first
    body = JSON.parse(response.body)
    assert_equal body['success'], true
  end

  test 'delete destroy should destroy the account and user' do
    prepare_master_account
    account = FactoryBot.create(:provider_account, provider_account: master_account, partner: @partner)
    user = account.admin_users.first!
    delete :destroy, params: { id: account.id, api_key: @partner.api_key }
    assert_raise(ActiveRecord::RecordNotFound){ account.reload }
    assert_raise(ActiveRecord::RecordNotFound){ user.reload }
    body = JSON.parse(response.body)
    assert_equal body['success'], true
  end
end
