# frozen_string_literal: true

require 'test_helper'

class Signup::SignupParamsTest < ActiveSupport::TestCase
  test '#build_account_with_attributes_for_provider_account returns the account with the right params' do
    account = signup_params.build_account_with_attributes_for_provider_account(provider_account)
    assert_equal account_params[:org_name], account.org_name
    assert_equal account_params[:vat_rate].to_f, account.vat_rate
    assert_equal provider_account, account.provider_account
  end

  test '#build_user_with_attributes_for_account returns the account with the right params' do
    user = signup_params.build_user_with_attributes_for_account(account)
    assert_equal user_params[:email], user.email
    assert_equal user_params[:username], user.username
    assert_equal user_params[:first_name], user.first_name
    assert_equal user_params[:last_name], user.last_name
    assert_equal user_params[:password], user.password
    assert_equal user_params[:signup_type], user.signup_type
    assert_equal account, user.account
  end

  test '#plans returns the plans param' do
    assert_equal signup_params_hash[:plans], signup_params.plans
  end

  test '#defaults return the defaults param' do
    assert_equal signup_params_hash[:defaults], signup_params.defaults
  end

  test 'set validate_fields for account and user' do
    account = signup_params.build_account_with_attributes_for_provider_account(provider_account)
    user = signup_params.build_user_with_attributes_for_account(account)
    assert account.fields_validations?
    assert user.fields_validations?
  end

  test 'extra fields are accepted' do
    FactoryGirl.create(:fields_definition, account: provider_account, target: 'User', name: 'created_by')
    FactoryGirl.create(:fields_definition, account: provider_account, target: 'Account', name: 'extra_for_account')

    user_attributes = { email: 'emailTest@email.com', username: 'john', first_name: 'John', last_name: 'Doe',
                    password: '123456', password_confirmation: '123456', signup_type: :minimal, 'created_by': 'hi' }
    account_attributes = { org_name: 'Developer', vat_rate: 33, extra_fields: { extra_for_account: 'itWorks' } }
    signup_params =  Signup::SignupParams.new(user_attributes: user_attributes, account_attributes: account_attributes, plans: [], defaults: {})

    account = signup_params.build_account_with_attributes_for_provider_account(provider_account)
    user = signup_params.build_user_with_attributes_for_account(account)

    assert_equal 'hi', user.extra_fields[:created_by]
    assert_equal 'itWorks', account.extra_fields[:extra_for_account]
  end

  private

  def signup_params
    @signup_params ||= Signup::SignupParams.new({ user_attributes: user_params, account_attributes: account_params, plans: [], defaults: {} })
  end

  def signup_params_hash
    { user_attributes: user_params, account_attributes: account_params, plans: [], defaults: {} }
  end

  def account
    @account ||= Account.new(account_params)
  end

  def provider_account
    @provider_account ||= FactoryGirl.create(:provider_account)
  end

  def user_params
    { email: 'emailTest@email.com', username: 'john', first_name: 'John', last_name: 'Doe',
      password: '123456', password_confirmation: '123456', signup_type: :minimal }
  end

  def account_params
    { org_name: 'Developer', vat_rate: 33 }
  end
end
