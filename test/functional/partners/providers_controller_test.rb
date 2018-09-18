require 'test_helper'

class Partners::ProvidersControllerTest < ActionController::TestCase

  should route(:post, "http://#{master_account.domain}/partners/providers").to(action: 'create', format: :json)

  def setup
    @request.host = master_account.domain
    @partner = FactoryGirl.create(:partner, system_name: 'someone')
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

  test 'required api_key' do
    post :create
    assert_response 401
    assert_equal 'unauthorized', response.body
  end

  test 'post create should create a user with account' do
    prepare_master_account
    assert_difference('Account.providers.count', 1) do
      post :create, provider_params
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

    assert_equal "troloro-#{@partner.system_name}.#{ThreeScale.config.superdomain}", account.domain
    assert_equal "troloro-#{@partner.system_name}-admin.#{ThreeScale.config.superdomain}", account.self_domain
    assert_equal "#{@partner.system_name}-#{provider_params[:org_name]}", account.org_name
    assert_equal @partner.application_plans.first, account.bought_cinstance.plan

    assert_equal @partner, Account.find(account.id).partner
    assert account.default_service.present?
    assert account.settings.monthly_billing_enabled
    refute account.settings.monthly_charging_enabled

    body = JSON.parse(response.body)
    assert_equal body['id'], account.id
    assert_equal body['provider_key'], account.api_key
    assert_equal body['end_point'], account.self_domain
    assert_equal body['success'], true
  end

  test 'post with specific password' do
    prepare_master_account
    post :create, provider_params.merge(password: 'foobar123')
    user = assigns(:user)
    account = assigns(:account)
    strategy = Authentication::Strategy::Internal.new(account, true)
    assert strategy.authenticate(username: user.username, password: 'foobar123')
    body = JSON.parse(response.body)
    assert_equal body['success'], true
  end

  test 'post with an invalid email' do
    prepare_master_account
    post :create, provider_params.merge(email: 'invalid')
    body = JSON.parse(response.body)
    refute body["success"]
    assert body["errors"]["user"]["email"].present?
    assert_equal "422", response.code
  end

  test 'post with a existing subdomain' do
    prepare_master_account
    post :create, provider_params.merge(subdomain: 'taken')
    post :create, provider_params.merge(subdomain: 'taken')

    body = JSON.parse(response.body)
    refute body["success"]
    assert body["errors"]["account"]["subdomain"].present?
    assert_equal "422", response.code
  end

  test 'post with different plan' do
    prepare_master_account
    post :create, provider_params.merge(application_plan: @partner.application_plans.last.system_name)
    assert_equal assigns(:account).bought_cinstance.plan, @partner.application_plans.last
    body = JSON.parse(response.body)
    assert_equal body['success'], true
  end

  test 'put update should change plan' do
    prepare_master_account
    post :create, provider_params
    account = assigns(:account)

    # upgrade
    put :update, id: account.id, application_plan: @partner.application_plans.last.system_name, api_key: @partner.api_key
    assert_equal account.reload.bought_cinstance.plan, @partner.application_plans.last
    body = JSON.parse(response.body)
    assert_equal body['success'], true

    # downgrade
    put :update, id: account.id, application_plan: @partner.application_plans.first.system_name, api_key: @partner.api_key
    assert_equal account.reload.bought_cinstance.plan, @partner.application_plans.first
    body = JSON.parse(response.body)
    assert_equal body['success'], true
  end

  test 'delete destroy should destroy the account and user' do
    prepare_master_account
    post :create, provider_params
    delete :destroy, id: assigns(:account).id, api_key: @partner.api_key
    assert_raise(ActiveRecord::RecordNotFound){ assigns(:account).reload }
    assert_raise(ActiveRecord::RecordNotFound){ assigns(:user).reload }
    body = JSON.parse(response.body)
    assert_equal body['success'], true
  end
end
