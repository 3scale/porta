# frozen_string_literal: true

require 'test_helper'

class PaymentTransactionTest < ActiveSupport::TestCase
  should belong_to :account
  should belong_to :invoice
  should validate_presence_of :amount

  def setup
    @transaction = PaymentTransaction.new(amount: 1000.to_has_money('JPY'))
  end

  test 'get and set amount as money' do
    @transaction.save!
    @transaction.reload
    assert_same 1000.to_has_money('JPY'), @transaction.amount
  end

  test 'with card stored in BogusGateway process without problems' do
    @gateway = ActiveMerchant::Billing::BogusGateway.new
    @transaction.amount = 100.to_has_money('EUR')

    @transaction.process!('1', @gateway, {})

    assert @transaction.success?
    assert_equal 100.to_has_money('EUR'), @transaction.amount
  end

  test "with many transactions have succeeded and failed scoped" do
    3.times { FactoryBot.create(:payment_transaction, success: true) }
    2.times { FactoryBot.create(:payment_transaction, success: false) }
    assert_equal 3, PaymentTransaction.succeeded.count
    assert_equal 2, PaymentTransaction.failed.count
  end

  test "#to_xml convert params attr correctly" do
    braintree_hash = { "braintree_transaction" =>
                        {"order_id"=>"123456", "status"=>"submitted_for_settlement",
                        "credit_card_details"=>{"masked_number"=>"123456******6789", "bin"=>"123456", "last_4"=>"6789", "card_type"=>"Visa"},
                        "customer_details"=>{"id"=>"98765432", "email"=>nil},
                        "billing_details"=>{"street_address"=>"yanabe Street", "extended_address"=>nil, "company"=>"barmajeyat.com",
                                            "locality"=>"Amman", "region"=>"Amman", "postal_code"=>"11190", "country_name"=>"Jordan"},
                        "shipping_details"=>{"street_address"=>nil, "extended_address"=>nil, "company"=>nil, "locality"=>nil,
                                              "region"=>nil, "postal_code"=>nil, "country_name"=>nil},
                        "vault_customer"=>{"credit_cards"=>[{"bin"=>"123456"}]},
                        "merchant_account_id"=>"bestmerchant"}}

    pt = FactoryBot.create(:payment_transaction, params: braintree_hash)

    xml = Nokogiri::XML::Document.parse(pt.to_xml)

    assert xml.xpath('.//gateway_response/braintree_transaction').presence
    assert xml.xpath('.//gateway_response/braintree_transaction/order_id').presence
    assert xml.xpath('.//gateway_response/braintree_transaction/credit_card_details').presence
    assert xml.xpath('.//gateway_response/braintree_transaction/customer_details').presence
    assert xml.xpath('.//gateway_response/braintree_transaction/billing_details').presence
    assert xml.xpath('.//gateway_response/braintree_transaction/shipping_details').presence
    assert xml.xpath('.//gateway_response/braintree_transaction/vault_customer/credit_cards').presence
    assert xml.xpath('.//gateway_response/braintree_transaction/merchant_account_id').presence
  end
end
