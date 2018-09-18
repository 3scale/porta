require 'test_helper'

class PaymentDetailsTest < ActiveSupport::TestCase

  setup do
    @cc_attributes = {
      credit_card_auth_code: 'auth_code',
      credit_card_partial_number: '1111',
      credit_card_expires_on: Date.parse('2020-08-01'),
      credit_card_authorize_net_payment_profile_token: 'auth_net_token'
    }

    @account = FactoryGirl.create(:simple_account)

    @account.update_columns(@cc_attributes)
    PaymentDetail.where(account_id: @account.id).delete_all
    @account.reload
  end

  test 'create payment detail if any credit card data exists in account' do
    account = FactoryGirl.create(:simple_account)
    refute PaymentDetail.where(account_id: account.id).exists?

    Account.where(id: account.id).update_all(@cc_attributes)
    account.reload
    refute PaymentDetail.where(account_id: account.id).exists?

    # Auto create the payment detail
    assert account.payment_detail.persisted?
  end

  test 'build payment_detail on access' do
    account = FactoryGirl.create(:simple_account)
    assert account.payment_detail.new_record?
  end

  test 'delegate readers to payment_detail' do
    assert_equal @account.credit_card_auth_code, @account.payment_detail.buyer_reference
    assert_equal @account.credit_card_partial_number, @account.payment_detail.credit_card_partial_number
    assert_equal @account.credit_card_expires_on, @account.payment_detail.credit_card_expires_on
    assert_equal @account.credit_card_authorize_net_payment_profile_token, @account.payment_detail.payment_service_reference
  end

  test 'delegate writers to payment_details' do
    @account.credit_card_auth_code = 'buyer-123'
    @account.credit_card_partial_number = '2222'
    @account.credit_card_expires_on = Date.parse('2018-02-01')
    @account.credit_card_authorize_net_payment_profile_token = nil

    assert_equal 'buyer-123', @account.payment_detail.buyer_reference
    assert_equal '2222', @account.payment_detail.credit_card_partial_number
    assert_equal '2018-02-01', @account.payment_detail.credit_card_expires_on.to_s
    assert_nil @account.payment_detail.payment_service_reference
  end

  test 'clear old cc attribute values in Account' do
    @account.credit_card_auth_code = 'buyer-123'
    @account.credit_card_partial_number = '2222'
    @account.credit_card_expires_on = Date.parse('2018-02-01')
    @account.credit_card_authorize_net_payment_profile_token = nil

    assert_equal 'buyer-123', @account.payment_detail.buyer_reference
    assert_equal '2222', @account.payment_detail.credit_card_partial_number
    assert_equal '2018-02-01', @account.payment_detail.credit_card_expires_on.to_s
    assert_nil @account.payment_detail.payment_service_reference

    assert_nil @account.read_attribute(:credit_card_auth_code)
    assert_nil @account.read_attribute(:credit_card_partial_number)
    assert_nil @account.read_attribute(:credit_card_expires_on)
    assert_nil @account.read_attribute(:credit_card_authorize_net_payment_profile_token)
  end

  test 'saves payment_detail together with account' do
    assert_difference 'PaymentDetail.count' do
      @account.payment_detail
      @account.save
    end
  end

  test 'destroy payment_detail together with account' do
    account_id = @account.id

    @account.payment_detail
    @account.save

    assert_difference 'PaymentDetail.count', -1 do
      @account.destroy
    end
  end

  test 'delegates audits on cc attributes to payment detail' do
    PaymentDetail.with_auditing do

      @account.credit_card_partial_number ='1111'
      @account.save

      payment_detail = @account.payment_detail

      audit = payment_detail.audits.last
      assert_equal 'create', audit.action

      @account.credit_card_partial_number = '2222'
      @account.save

      audit = payment_detail.audits.last
      assert_equal 'update', audit.action
      assert_equal ['1111', '2222'], audit.audited_changes['credit_card_partial_number']

      @account.delete_cc_details
      @account.save

      audit = payment_detail.audits.last
      assert_equal 'update', audit.action
      assert_equal ['2222', nil], audit.audited_changes['credit_card_partial_number']
    end
  end
end
