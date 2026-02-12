# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::AccountsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @master = master_account
    login! @master
    @account_plan = @master.default_account_plan
    @service_plan = master.default_service_plans.first
    @application_plan = master.default_application_plans.first
    @application_plan.update(system_name: 'enterprise') # for the switches tested later
    FactoryBot.create(:fields_definition, account: @master, target: 'User', name: 'created_by')
  end

  test '#create without approval required' do
    # sends activation email
    ProviderUserMailer.expects(:activation).returns(mock(deliver_later: true))

    account_plan.update(approval_required: false)
    post provider_admin_accounts_path, params: valid_params
    user = User.find_by!(email: valid_params[:account][:user][:email])
    account = user.account

    # because it sent activation email
    assert user.pending?
    assert_not user.can_login?

    # creates the main user with its right attributes
    assert_equal 'foo@example.com', user.email
    assert_equal 'hello', user.username
    assert_equal 'hi', user.extra_fields['created_by']
    assert_equal :created_by_provider, user.signup_type

    # creates the account with its right attributes
    assert_equal 'Alaska', account.org_name
    assert account.approved?
    assert_equal valid_params[:account][:org_name], account.name
    assert_equal valid_params[:account][:org_name].downcase, account.subdomain
    assert_equal "#{valid_params[:account][:org_name].downcase}-admin", account.self_subdomain

    # creates the account with its impersonation_admin user
    assert account.has_impersonation_admin?

    # redirects to the account page and has the right flash message
    assert_redirected_to admin_buyers_account_path(account)
    assert_equal 'Tenant account was successfully created', flash[:success]

    # sets the limits
    constraints = User.find_by!(email: valid_params[:account][:user][:email]).account.provider_constraints
    assert_nil constraints.max_users
    assert_nil constraints.max_services
    assert constraints.can_create_service?
    assert constraints.can_create_user?
  end

  test '#create for on-prem' do
    ThreeScale.config.stubs(onpremises: true)
    post provider_admin_accounts_path, params: valid_params
    account = User.find_by!(email: valid_params[:account][:user][:email]).account
    # account has the right plans
    assert_equal account_plan, account.bought_account_plan
    assert_equal [service_plan], account.bought_service_plans
    assert_equal [application_plan], account.bought_application_plans
    # should set the switches to everything is allowed (because it is enterprise and for on-prem it is validated)
    account.settings.switches.each { |_name, switch| assert switch.allowed? }
  end

  test '#create for saas' do
    ThreeScale.config.stubs(onpremises: false)
    post provider_admin_accounts_path, params: valid_params
    account = User.find_by!(email: valid_params[:account][:user][:email]).account
    # account has the right plans
    assert_equal account_plan, account.bought_account_plan
    assert_equal [service_plan], account.bought_service_plans
    assert_equal [application_plan], account.bought_application_plans
    # should set the switches to nothing is allowed (because the enterprise plan for saas is not automatically validated)
    switches = account.settings.switches
    switches.each { |_name, switch| assert_not switch.allowed? }
  end

  test '#create approves the account when the account plan does not require approval' do
    account_plan.update(approval_required: true)
    post provider_admin_accounts_path, params: valid_params
    user = User.find_by!(email: valid_params[:account][:user][:email])
    account = user.account
    assert_not user.can_login?
    assert account.created?
  end

  private

  attr_reader :master, :account_plan, :service_plan, :application_plan

  def valid_params
    {
      account: {
        org_name: 'Alaska',
        user: { email: 'foo@example.com', extra_fields: { created_by: 'hi' }, password: 'superSecret1234#', username: 'hello' }
      }
    }
  end
end
