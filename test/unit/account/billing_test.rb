require 'test_helper'

class Account::BillingTest < ActiveSupport::TestCase

  test 'with_billing finds only Accounts with billings strategies' do
    account_one = Factory.create(:simple_provider, :billing_strategy => Factory(:postpaid_billing))
    account_two = Factory.create(:simple_provider, :billing_strategy => nil)

    assert_contains         Account.with_billing, account_one
    assert_does_not_contain Account.with_billing, account_two
  end

  test 'serializes payment_gateway_options' do
    account = Factory(:simple_account, :payment_gateway_options => {:foo => 'bar'})
    account.reload

    assert_equal 'bar', account.payment_gateway_options[:foo]
  end

  test 'symbolizes keys of payment_gateway_options' do
    account = Factory(:simple_account, :payment_gateway_options => {'foo' => 'bar'})
    account.reload

    assert_equal 'bar', account.payment_gateway_options[:foo]
    assert_nil          account.payment_gateway_options['foo']
  end

  should 'be nil by default' do
    account = Factory(:simple_account)
    assert_nil account.payment_gateway
  end

  should 'return active merchant gateway according to type and options' do
    account = Factory(:simple_account, :payment_gateway_type => :braintree_blue,
                      :payment_gateway_options => {:public_key => 'foo',
                        :merchant_id => 'bar',
                        :private_key => 'pkey'})

    assert_not_nil account.payment_gateway
    assert_instance_of ActiveMerchant::Billing::BraintreeBlueGateway, account.payment_gateway
    assert_equal 'foo', account.payment_gateway.options[:public_key]
    assert_equal 'bar', account.payment_gateway.options[:merchant_id]
    assert_equal 'pkey', account.payment_gateway.options[:private_key]
  end


  should 'return payment gateway of provider_account' do
    provider_account = Factory(:simple_provider)
    buyer_account = Factory(:simple_buyer, :provider_account => provider_account)

    assert_same provider_account.payment_gateway, buyer_account.provider_payment_gateway
  end


  should 'return false by default' do
    assert !Account.new.credit_card_stored?
  end

  test 'unstore credit card when destroyed' do
    provider = Factory(:simple_provider)
    buyer = Factory(:account, :provider_account => provider,
                    :credit_card_auth_code => 'SOMESTRING')

    provider.payment_gateway.expects(:threescale_unstore).with('SOMESTRING')
    buyer.destroy
  end


  should 'return masked credit card number on credit_card_display_number' do
    account = Factory.build(:simple_account)
    account.credit_card_partial_number = '1234'
    account.save!

    assert_equal 'XXXX-XXXX-XXXX-1234', account.credit_card_display_number
  end

  should 'return nil on credit_card_display_number if credit_card_partial_number is nil' do
    account = Factory.build(:simple_account)
    assert_nil account.credit_card_display_number
  end

  should 'return current year and month on credit_card_expires_on_with_default if no credit card is stored' do
    Timecop.freeze(Time.zone.local(2009, 8, 12)) do
      account = Factory.build(:simple_account)
      assert_equal Date.new(2009, 8, 1), account.credit_card_expires_on_with_default
    end
  end

  should 'set credit card expiration date using year and month attributes' do
    account = Factory(:simple_account)
    account.credit_card_expires_on_year = 2020
    account.credit_card_expires_on_month = 2
    account.save!
  end

  test 'accepts 2-digit year' do
    account = Account.new
    account.credit_card_expires_on_year = 25
    account.credit_card_expires_on_month = 2
    assert_equal '2025-02-01', account.credit_card_expires_on.to_s
  end

  should 'return false if credit card is stored but expired' do
    account = Factory(:simple_account, :provider_account => Factory(:simple_provider),
                      :credit_card_auth_code => '123', :credit_card_expires_on => Date.new(2009,8,12))
    assert_equal Date.new(2009, 8, 12), account.credit_card_expires_on_with_default
  end

  should 'return false if credit card is not stored' do
    account = Factory(:simple_account)
    assert !account.credit_card_stored_and_valid?
  end

  should 'return true if credit card is stored and not expired' do
    account = Factory(:simple_account, :provider_account => Factory(:simple_provider),
                      :credit_card_auth_code => '123', :credit_card_expires_on => Date.new(2020,8,12))

    assert account.credit_card_stored_and_valid?
  end


  should 'return true if credit card is stored and not expired' do
    account = Factory(:simple_account, :provider_account => Factory(:simple_provider),
                      :credit_card_auth_code => '123', :credit_card_expires_on => 1000.years.from_now)
    assert account.credit_card_stored_and_valid?
  end

  should 'not take a country by default' do
    account = Account.new
    assert_nil account.billing_address_country
    assert_nil account.billing_address.country
  end


  test 'update invoices vat rate only when changed' do
    provider = FactoryBot.create(:simple_provider)
    account = FactoryBot.create(:simple_account, provider_account: provider, vat_rate: 1.0)

    invoice = account.invoices.create!(provider_account: provider,
                                       period: '2016-06',
                                       friendly_id: '2016-06-00000001')
    invoice.update_columns(vat_rate: 2.0)
    assert_equal 2.0, invoice.reload.vat_rate.to_f

    account.reload
    account.save
    assert_equal 2.0, invoice.reload.vat_rate.to_f

    account.vat_rate = 3.0
    account.save
    assert_equal 3.0, invoice.reload.vat_rate.to_f
  end

  test 'check_unresolved_invoices except for the buyers scheduled for deletion' do
    number_buyers = 2
    provider = FactoryBot.create(:simple_provider)
    FactoryBot.create_list(:simple_buyer, number_buyers, provider_account: provider)
        .each { |buyer| buyer.invoices.create!(provider_account: provider, period: '2016-06', friendly_id: '2016-06-00000001', state: 'pending') }

    assert_raise(ActiveRecord::RecordNotDestroyed) { provider.destroy! }
    refute provider.destroyed?

    provider.schedule_for_deletion!

    provider.buyers.last!.destroy!
    assert_equal number_buyers-1, provider.buyers.count

    provider.destroy!
    assert provider.destroyed?
  end

end
