require 'test_helper'

class Admin::Api::CreditCardsControllerTest < ActionController::TestCase

  def setup
    provider = FactoryGirl.create(:provider_account)
    @buyer   = FactoryGirl.create(:buyer_account, provider_account: provider)

    @params = {
      id: @buyer.provider_account_id,
      account_id: @buyer.id,
      credit_card_token: "buyer-#{@buyer.provider_account_id}-#{@buyer.id}",
      credit_card_partial_number: '1111',
      credit_card_expiration_year: '25',
      credit_card_expiration_month: '03',
      billing_address_name: 'Office',
      billing_address_address: '888 Test St',
      billing_address_city: 'Nowhere',
      billing_address_country: 'Spain',
      billing_address_state: 'Barcelona',
      billing_address_phone: '+34567890123',
      billing_address_zip: '08013',
      format: :xml
    }

    login_provider provider
  end

  def test_update
    put :update, @params
    assert_response :success
  end

  test '2-digit expiry year' do
    put :update, @params
    assert_response :success
    assert_equal '2025-03-01', @buyer.reload.credit_card_expires_on.to_s
  end

  test '4-digit expiry year' do
    @params[:credit_card_expiration_year] = '2025'

    put :update, @params
    assert_response :success
    assert_equal '2025-03-01', @buyer.reload.credit_card_expires_on.to_s
  end

  def test_delete
    delete :destroy, id: @buyer.provider_account_id, account_id: @buyer.id, format: :xml
    assert_response :success
  end
end