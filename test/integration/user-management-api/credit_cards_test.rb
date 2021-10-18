# frozen_string_literal: true

require 'test_helper'

class Admin::Api::CreditCardsTest < ActionDispatch::IntegrationTest
  include FieldsDefinitionsHelpers
  include TestHelpers::ApiPagination

  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'

    @buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
    @buyer.buy! @provider.default_account_plan

    @application_plan = FactoryBot.create(:application_plan,
                                :issuer => @provider.default_service)
    @application_plan.publish!

    @buyer.buy! @application_plan


    host! @provider.admin_domain
    @provider.payment_gateway_type = :stripe
    @provider.save!
  end

  # Access token

  test 'update (access_token)' do
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['finance'])
    token = FactoryBot.create(:access_token, owner: user, scopes: 'finance')

    put(admin_api_account_credit_card_path(@buyer, format: :xml), params: valid_params(token))
    assert_response :success

    user.admin_sections = []
    user.save!

    put(admin_api_account_credit_card_path(@buyer, format: :xml), params: valid_params(token))
    assert_response :forbidden

    user.admin_sections = ['finance']
    user.save!
    token.scopes = ['cms']
    token.save!

    put(admin_api_account_credit_card_path(@buyer, format: :xml), params: valid_params(token))
    assert_response :forbidden
  end

  test 'destroy (access_token)' do
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['finance'])
    token = FactoryBot.create(:access_token, owner: user, scopes: 'finance')

    delete(admin_api_account_credit_card_path(@buyer, format: :xml), params: { access_token: token.value })
    assert_response :success

    user.role = 'admin'
    user.save!

    delete(admin_api_account_credit_card_path(@buyer, format: :xml), params: { access_token: token.value })
    assert_response :success
  end

  # Provider key

  test 'credit_card_stored is false if buyer has no cc' do
    @provider.update!(payment_gateway_type: :bogus)

    get(admin_api_account_path(@buyer, :format => :xml), params: { :provider_key => @provider.api_key })

    assert_response :success

    assert_account(@response.body, {
                     :credit_card_stored => false})
  end

  test 'credit_card_stored is true if buyer has cc' do
    @provider.update!(payment_gateway_type: :bogus)

    @buyer.credit_card_auth_code = 'foo'
    @buyer.save!
    get(admin_api_account_path(@buyer, :format => :xml), params: { :provider_key => @provider.api_key })

    assert_response :success

    assert_account(@response.body, {
                     :credit_card_stored => true})
  end

  test 'store_credit_card_info without required params fails' do
    assert !@buyer.credit_card_stored?
    @provider.payment_gateway_type = :braintree_blue
    @provider.save!
    @provider.reload

    put(admin_api_account_credit_card_path(@buyer, :format => :xml), params: { :provider_key => @provider.api_key })
    @buyer.reload
    assert !@buyer.credit_card_stored?
  end

  test 'store_credit_card_info with wrong month fails' do
    assert !@buyer.credit_card_stored?
    @provider.payment_gateway_type = :braintree_blue
    @provider.save!
    @provider.reload

    put(admin_api_account_credit_card_path(@buyer, :format => :xml), params: { :credit_card_token => 'secret', :credit_card_partial_number => '1234', :billing_address_name => 'foo', :billing_address_address => 'elm street', :billing_address_city => 'sin city', :billing_address_country => 'spain', :credit_card_expiration_year => '2013', :credit_card_expiration_month => '13', :provider_key => @provider.api_key })

    assert_response :unprocessable_entity

    @buyer.reload
    assert !@buyer.credit_card_stored?
  end

  test 'store_credit_card_info with wrong address fails' do
    assert !@buyer.credit_card_stored?
    @provider.payment_gateway_type = :braintree_blue
    @provider.save!
    @provider.reload

    put(admin_api_account_credit_card_path(@buyer, :format => :xml), params: { :credit_card_token => 'secret', :credit_card_partial_number => '1234', :billing_address_name => 'foo', :billing_address_address => ' ', :billing_address_city => 'sin city', :billing_address_country => 'spain', :credit_card_expiration_year => '2013', :credit_card_expiration_month => '13', :provider_key => @provider.api_key })

    assert_response :unprocessable_entity

    @buyer.reload
    assert !@buyer.credit_card_stored?
  end


  test 'store_credit_card_info without needed params for auth.net fails' do
    assert !@buyer.credit_card_stored?
    @provider.update_attribute(:payment_gateway_type, :authorize_net) # to prevent ActiveRecord::RecordInvalid since the payment gateway has been deprecated
    @provider.reload
    put(admin_api_account_credit_card_path(@buyer, :format => :xml), params: { :credit_card_token => 'fdsa', :provider_key => @provider.api_key })

    @buyer.reload
    assert_response :unprocessable_entity
    assert !@buyer.credit_card_stored?
  end

  test 'ok store_credit_card_info' do
    assert !@buyer.credit_card_stored?
    @provider.payment_gateway_type = :braintree_blue
    @provider.save!
    @provider.reload

    put(admin_api_account_credit_card_path(@buyer, :format => :xml), params: { :credit_card_token => 'secret', :credit_card_partial_number => '1234', :billing_address_name => 'foo', :billing_address_address => 'elm street', :billing_address_city => 'sin city', :billing_address_country => 'spain', :credit_card_expiration_year => '2013', :credit_card_expiration_month => '12', :provider_key => @provider.api_key })
    @buyer.reload

    assert @buyer.credit_card_stored?
    assert_equal 'secret', @buyer.credit_card_auth_code
    assert_equal '1234', @buyer.credit_card_partial_number
    assert_equal 'foo', @buyer.billing_address_name
    assert_equal 'elm street', @buyer.billing_address_address1
    assert_equal 'sin city', @buyer.billing_address_city
    assert_equal 'spain', @buyer.billing_address_country
    assert_equal Date.parse('2013/12'), @buyer.credit_card_expires_on_with_default
  end

  test 'ok store_credit_card_info for authorize_net' do
    assert !@buyer.credit_card_stored?
    @provider.update_attribute(:payment_gateway_type, :authorize_net) # to prevent ActiveRecord::RecordInvalid since the payment gateway has been deprecated
    @provider.reload

    put(admin_api_account_credit_card_path(@buyer, :format => :xml), params: { :credit_card_token => 'secret', :credit_card_authorize_net_payment_profile_token => 'cctoken', :credit_card_partial_number => '1234', :billing_address_name => 'foo', :billing_address_address => 'elm street', :billing_address_city => 'sin city', :billing_address_country => 'spain', :credit_card_expiration_year => '2013', :credit_card_expiration_month => '12', :provider_key => @provider.api_key })
    @buyer.reload

    assert @buyer.credit_card_stored?
    assert_equal 'secret', @buyer.credit_card_auth_code
    assert_equal 'cctoken', @buyer.credit_card_authorize_net_payment_profile_token
    assert_equal '1234', @buyer.credit_card_partial_number
    assert_equal 'foo', @buyer.billing_address_name
    assert_equal 'elm street', @buyer.billing_address_address1
    assert_equal 'sin city', @buyer.billing_address_city
    assert_equal 'spain', @buyer.billing_address_country
    assert_equal Date.parse('2013/12'), @buyer.credit_card_expires_on_with_default
  end


  test 'delete_credit_card_info' do
    @buyer.payment_detail.delete
    FactoryBot.create(:payment_detail, account: @buyer)
    assert @buyer.reload.credit_card_stored?

    delete(admin_api_account_credit_card_path(@buyer, :format => :xml), params: { :provider_key => @provider.api_key })
    @buyer.reload

    assert !@buyer.credit_card_stored?
    assert !@buyer.billing_address?
  end

  private

  def valid_params(token)
    {
      credit_card_token:            'secret',
      credit_card_partial_number:   '1234',
      billing_address_name:         'foo',
      billing_address_address:      'elm street',
      billing_address_city:         'sin city',
      billing_address_country:      'spain',
      credit_card_expiration_year:  '2013',
      credit_card_expiration_month: '12',
      access_token:                 token.value
    }
  end
end
