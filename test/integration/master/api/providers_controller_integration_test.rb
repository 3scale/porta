# frozen_string_literal: true

require 'test_helper'

class Master::Api::ProvidersControllerIntegrationTest < ActionDispatch::IntegrationTest

  def setup
    @account_plan = master_account.default_account_plan
    @account_plan.update(approval_required: false)
    @service_plan = master_account.default_service_plans.first
    @application_plan = master_account.default_application_plans.first

    FactoryBot.create(:fields_definition, account: master_account, target: 'Account', name: 'account_extra_field')
    FactoryBot.create(:fields_definition, account: master_account, target: 'User', name: 'user_extra_field')

    master_account.stubs(:provider_can_use?).with(:service_permissions).returns(true)

    host! master_account.internal_admin_domain
  end

  test '#create' do
    # sends activation email
    ProviderUserMailer.expects(:activation).returns(mock(deliver_later: true))

    # persists the new provider
    assert_difference Account.method(:count), 1 do
      assert_difference User.method(:count), 2 do # the main user and the 3
        assert_difference AccessToken.method(:count), 1 do
          post master_api_providers_path, params: signup_params
          assert_response :created
        end
      end
    end

    # returns the right data
    json_response = JSON.parse(response.body)
    assert_equal account.id, json_response.dig('signup', 'account', 'id')

    # creates the main user with its right attributes
    assert_not user.can_login?
    assert user.pending?
    assert_equal signup_params[:username], user.username
    assert_equal signup_params[:user_extra_field], user.extra_fields['user_extra_field']
    assert_equal :created_by_provider, user.signup_type

    # creates the account with its right attributes
    assert account.approved?
    assert_equal 'Alaska', account.org_name
    assert_equal signup_params[:account_extra_field], account.extra_fields['account_extra_field']
    assert_equal signup_params[:org_name], account.name
    assert_equal signup_params[:org_name].downcase, account.subdomain
    assert_equal "#{signup_params[:org_name].downcase}-admin", account.self_subdomain

    # creates the account with its impersonation_admin user
    assert account.has_impersonation_admin?

    # creates account plans correctly
    assert_equal account_plan, account.bought_account_plan
    assert_equal [service_plan], account.bought_service_plans
    assert_equal [application_plan], account.bought_application_plans

    # returns an access token for the user with rw permissions for 'account management api'
    assert_equal user.access_tokens.first.id, json_response.dig('signup', 'access_token', 'id')
  end

  test '#create with published account plan sent (for Saas) as a param that requires approval' do
    ThreeScale.config.stubs(onpremises: false)
    new_account_plan = FactoryBot.create(:account_plan, approval_required: true, issuer: master_account, state: 'published')
    post master_api_providers_path, params: signup_params({ account_plan_id: new_account_plan.id })
    assert_not user.can_login?
    assert user.pending?
    assert account.created?
    assert account.has_impersonation_admin?
    assert_equal new_account_plan, account.bought_account_plan
  end

  test '#create with unpublished account plan sent (for Saas) as a param that requires approval' do
    ThreeScale.config.stubs(onpremises: false)
    new_account_plan = FactoryBot.create(:account_plan, approval_required: true, issuer: master_account, state: 'hidden')
    post master_api_providers_path, params: signup_params({ account_plan_id: new_account_plan.id })
    assert_not user.can_login?
    assert user.pending?
    assert account.created?
    assert account.has_impersonation_admin?
    assert_equal new_account_plan, account.bought_account_plan
  end

  test '#create with account plan send (for on-premises) is ignored' do
    ThreeScale.config.stubs(onpremises: true)
    new_account_plan = FactoryBot.create(:account_plan, issuer: master_account)
    post master_api_providers_path, params: signup_params({ account_plan_id: new_account_plan.id })
    assert_equal account_plan, account.bought_account_plan
  end

  test '#create returns the right errors when account validation fails' do
    post master_api_providers_path, params: signup_params({ org_name: '' })
    assert_response :unprocessable_entity
    assert_contains JSON.parse(response.body).dig('errors', 'account'), 'Domain can\'t be blank'
  end

  test '#create returns the right errors when user validation fails for json' do
    post master_api_providers_path, params: signup_params({ email: '' })
    assert_response :unprocessable_entity
    assert_contains JSON.parse(response.body).dig('errors', 'user'), 'Email should look like an email address'
  end

  test '#create returns the right errors when user validation fails for xml' do
    post master_api_providers_path(format: :xml), params: signup_params({ email: '' })
    assert_response :unprocessable_entity
    assert_xml Nokogiri::XML::Document.parse(response.body), '//errors/error', /User Email should look like an email address/
  end

  test '#create without the api_key or access_token, the response status should be unauthorized' do
    post master_api_providers_path, params: signup_params({ api_key: '', access_token: '' })
    assert_response :unauthorized
  end

  test '#create returns unauthorized when the provider_key param is sent instead of api_key or access_token' do
    post master_api_providers_path, params: signup_params({ provider_key: master_account.api_key, api_key: '', access_token: '' })
    assert_response :unauthorized
  end

  test '#create with access_token instead of api_key works as well' do
    token = FactoryBot.create(:access_token, owner: master_account.admins.first, scopes: 'account_management')
    assert_difference Account.method(:count), 1 do
      assert_difference User.method(:count), 2 do # the main user and the impersonation_admin user
        post master_api_providers_path, params: signup_params({ api_key: '', access_token: token.value })
        assert_response :created
      end
    end
  end

  test '#create is forbidden for a member user without member permission partners' do
    assert_no_difference Account.method(:count) do
      user = FactoryBot.create(:member, account: master_account)
      token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')
      post master_api_providers_path, params: signup_params({ access_token: token.value }).except(:api_key)
      assert_response :forbidden
      assert_equal 'Your access token does not have the correct permissions', JSON.parse(response.body)['error']
    end
  end

  test '#create is allowed for a member user with member permission partner' do
    assert_difference Account.method(:count) do
      user = FactoryBot.create(:member, account: master_account, member_permission_ids: [:partners])
      token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')
      post master_api_providers_path, params: signup_params({ access_token: token.value }).except(:api_key)
      assert_response :created
    end
  end

  test '#create for a master without account plan, the response status should be unprocessable_entity' do
    account_plan.destroy!
    post master_api_providers_path, params: signup_params
    assert_response :unprocessable_entity
  end

  test '#create for a master without service plan, the response status should be unprocessable_entity' do
    service_plan.destroy!
    post master_api_providers_path, params: signup_params
    assert_response :unprocessable_entity
  end

  test '#update' do
    provider = FactoryBot.create(:provider_account, provider_account: master_account)
    user     = FactoryBot.create(:member, account: master_account, admin_sections: ['partners'])
    token    = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

    update_params = { account: {
      from_email: 'from@email.com', support_email: 'support@email.com',
      finance_support_email: 'finance@email.com', site_access_code: 'new-access-code',
      account_extra_field: 'testing-account-extra-field', state_event: 'suspend'
    }, access_token: token.value, format: :json }
    put master_api_provider_path(provider, update_params)
    assert_response :ok

    provider.reload
    assert_equal update_params[:account][:from_email],            provider.from_email
    assert_equal update_params[:account][:support_email],         provider.support_email
    assert_equal update_params[:account][:finance_support_email], provider.finance_support_email
    assert_equal update_params[:account][:site_access_code],      provider.site_access_code
    assert_equal update_params[:account][:account_extra_field],   provider.extra_fields['account_extra_field']
    assert_equal 'suspended',                                     provider.state
  end

  test '#update can only resume when the account is scheduled_for_deletion' do
    provider = FactoryBot.create(:provider_account, provider_account: master_account)
    user     = FactoryBot.create(:member, account: master_account, admin_sections: ['partners'])
    token    = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')
    provider.schedule_for_deletion!

    update_params = { account: { from_email: 'from@email.com', state_event: 'resume'},
                      access_token: token.value, format: :json }
    put master_api_provider_path(provider, update_params)
    assert_response :ok

    provider.reload
    assert_not_equal update_params[:account][:from_email], provider.from_email
    assert_equal 'approved',                           provider.state
  end

  test '#destroy' do
    provider = FactoryBot.create(:provider_account, provider_account: master_account)
    user     = FactoryBot.create(:member, account: master_account, admin_sections: ['partners'])
    token    = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

    freeze_time do
      delete master_api_provider_path(provider, access_token: token.value, format: :json)
      assert_response :ok
      assert_equal '', response.body
      assert provider.reload.scheduled_for_deletion?
      assert_equal Time.zone.now.to_s, provider.state_changed_at.to_s
    end
  end

  test '#destroy is forbidden for a member user without member permission partners' do
    provider = FactoryBot.create(:provider_account, provider_account: master_account)
    user     = FactoryBot.create(:member, account: master_account)
    token    = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')
    delete master_api_provider_path(provider, access_token: token.value, format: :json)
    assert_response :forbidden
    assert_equal 'Your access token does not have the correct permissions', JSON.parse(response.body)['error']
  end

  test '#show' do
    provider = FactoryBot.create(:provider_account, provider_account: master_account)
    token    = FactoryBot.create(:access_token, owner: master_account.admin_users.first, scopes: 'account_management')

    get master_api_provider_path(provider, access_token: token.value, format: :json)

    assert_response :ok
    assert_equal provider.reload.id, JSON.parse(response.body).dig('signup', 'account', 'id')
  end

  private

  attr_reader :service_plan, :account_plan, :application_plan

  def user
    @user ||= User.find_by!(email: signup_params[:email])
  end

  def account
    @account ||= user.account
  end

  def signup_params(different_params = {})
    {
      api_key: master_account.api_key,
      org_name: 'Alaska',
      username: 'person',
      email: 'person@example.com',
      password: 'superSecret1234#',
      user_extra_field: 'hi-user',
      account_extra_field: 'hi-account'
    }.merge(different_params)
  end

  class ProviderUpgradeTest < ActionDispatch::IntegrationTest
    def setup
      # master_account.stubs(:provider_can_use?).with(:service_permissions).returns(true)
      #
      host! master_account.internal_admin_domain

      @provider = FactoryBot.create(:provider_account, provider_account: master_account)
      @token = FactoryBot.create(:access_token, owner: master_account.admin_users.first, scopes: 'account_management')
    end

    test '#plan_upgrade successful upgrade' do
      new_plan = FactoryBot.create(:application_plan, issuer: master_account.default_service)

      put plan_upgrade_master_api_provider_path(provider, access_token: token.value, plan_id: new_plan.id, format: :xml)

      assert_response :ok
      assert_equal new_plan.id, provider.reload.bought_application_plans.first.id
    end

    test '#plan_upgrade missing plan' do
      current_plan_id = provider.reload.bought_application_plans.first.id
      new_plan_id = 999
      put plan_upgrade_master_api_provider_path(provider, access_token: token.value, plan_id: new_plan_id, format: :xml)

      assert_response :not_found
      assert_equal current_plan_id, provider.reload.bought_application_plans.first.id
      assert_xml Nokogiri::XML::Document.parse(response.body), '//error', "Plan with ID #{new_plan_id} not found"
    end

    test '#plan_upgrade no stock plan' do
      new_plan_name = 'invalid-plan'
      new_plan = FactoryBot.create(:application_plan_without_rules, issuer: master_account.default_service, name: new_plan_name)
      current_plan_id = provider.reload.bought_application_plans.first.id

      put plan_upgrade_master_api_provider_path(provider, access_token: token.value, plan_id: new_plan.id, format: :xml)

      assert_response :bad_request
      assert_equal current_plan_id, provider.reload.bought_application_plans.first.id
      assert_xml Nokogiri::XML::Document.parse(response.body), '//error',
                 "Plan #{new_plan_name} is not one of the 3scale stock plans. Cannot automatically change to it."
    end

    private

    attr_reader :provider, :token
  end

end
