# frozen_string_literal: true

require 'test_helper'

class SignupExpressTest < ActionDispatch::IntegrationTest
  def setup
    @account_plan = FactoryBot.create(:account_plan, approval_required: true)
    @provider = @account_plan.provider
    host! @provider.external_admin_domain
  end

  test 'signup express with org name and name work equally' do
    post admin_api_signup_path(format: :xml), params: params(org_name: 'org name')
    assert_response :success
    doc = Nokogiri::XML::Document.parse(@response.body)
    assert_equal 'org name', doc.xpath('/account/org_name').text

    params_without_org_name = params(name: 'just name', username: 'another', email: 'another@example.com').except(:org_name)
    post admin_api_signup_path(format: :xml), params: params_without_org_name
    assert_response :success
    doc = Nokogiri::XML::Document.parse(@response.body)
    assert_equal 'just name', doc.xpath('/account/org_name').text
  end

  test 'signup express with account plan that requires approval' do
    post admin_api_signup_path(format: :xml), params: params

    signup_result = assigns(:signup_result)
    assert signup_result.user.pending?
    assert signup_result.account.created?
    assert_equal @account_plan, signup_result.account.reload.bought_account_plan
  end

  test 'signup express with account plan that do not requires approval' do
    @account_plan.approval_required = false
    @account_plan.save!
    post admin_api_signup_path(format: :xml), params: params

    signup_result = assigns(:signup_result)
    assert signup_result.user_active?
    assert signup_result.account_approved?
    assert_equal @account_plan, signup_result.account.reload.bought_account_plan
  end

  test 'do not raise exception when validation fails for email duplications' do
    post admin_api_signup_path(format: :xml), params: params
    assert_response :success
    post admin_api_signup_path(format: :xml), params: params
    assert_response 422
  end

  test 'do not raise exception when account validations fails' do
    post admin_api_signup_path(format: :xml), params: params(org_name: '')
    assert_response 422
  end

  test 'set billing_address' do
    FactoryBot.create(:fields_definition, account: @provider, target: 'Account', name: 'billing_address', read_only: true)

    post admin_api_signup_path(format: :xml), params: params({ org_name: 'alaska', billing_address: 'Calle Napoles 187, Barcelona. Spain' })
    assert_response :unprocessable_entity
    doc = Nokogiri::XML::Document.parse(response.body)
    assert_equal 'Billing address is not correctly set', doc.xpath('//error/errors').text

    billing_address = { name: '3scale', address1: 'Calle Napoles 187', city: 'Barcelona', country:  'Spain' }
    billing_address_params_nested = billing_address.transform_keys { |k| "billing_address[#{k}]" }

    post admin_api_signup_path(format: :json), params: params(billing_address_params_nested)
    assert_response :success

    account_billing_address = response.parsed_body[:account][:billing_address]
    assert_equal '3scale', account_billing_address[:company]
    assert_equal 'Barcelona', account_billing_address[:city]
    assert_equal 'Spain', account_billing_address[:country]
    assert_equal 'Calle Napoles 187', account_billing_address[:address1]

    billing_address_params_strings = billing_address.transform_keys { |k| "billing_address_#{k}" }

    post admin_api_signup_path(format: :json), params: params({ username: 'another-user', email: 'another-user@example.com', **billing_address_params_strings })
    assert_response :success

    account_billing_address = response.parsed_body[:account][:billing_address]
    assert_equal '3scale', account_billing_address[:company]
    assert_equal 'Barcelona', account_billing_address[:city]
    assert_equal 'Spain', account_billing_address[:country]
    assert_equal 'Calle Napoles 187', account_billing_address[:address1]
  end

  test 'signup with annotations' do
    post admin_api_signup_path(format: :json), params: params.merge({ annotations: { managed_by: 'operator' } })

    assert_response :success

    account = response.parsed_body[:account]
    assert_equal({ 'managed_by' => 'operator'}, account[:annotations])

    new_account = Account.find(account[:id])
    assert_equal 'operator', new_account.annotations.where(name: 'managed_by').first.value
  end

  test 'signup with non-matching password fails' do
    post admin_api_signup_path(format: :json), params: params.merge({ password_confirmation: 'non-matching-password' })

    assert_response :unprocessable_entity

    errors = response.parsed_body[:errors]
    assert_equal ["invalid"], errors[:users]
    assert_equal ["doesn't match Password"], errors[:password_confirmation]
  end

  private

  def params(custom_params = {})
    {
      provider_key: @provider.api_key,
      name: 'example',
      org_name: 'company',
      username: 'quentin',
      email: 'quentin@example.com',
      password: 'superSecret1234#',
      account_plan_id: @account_plan.id
    }.merge(custom_params)
  end
end
