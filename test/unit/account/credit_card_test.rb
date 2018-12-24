require 'test_helper'

class Account::CreditCardTest < ActiveSupport::TestCase

  test 'credit_card_stored? return false by default' do
    refute Account.new.credit_card_stored?
  end

  test 'credit_card_stored? return true for authorize.net users iff have credit_card_auth_code and cc_token' do
    provider_account = FactoryBot.create(:simple_provider)
    account = FactoryBot.create(:simple_account, :provider_account => provider_account)
    provider_account.payment_gateway_type = :authorize_net
    account.credit_card_auth_code = 'code'
    refute account.credit_card_stored?

    account.credit_card_authorize_net_payment_profile_token = 'code'
    assert account.credit_card_stored?
  end

  test 'credit_card_stored_attribute' do
    provider_account = FactoryBot.create(:simple_provider)
    account = FactoryBot.create(:simple_account, provider_account: provider_account, payment_gateway_type: nil)

    assert_equal :credit_card_auth_code, account.credit_card_stored_attribute

    provider_account.payment_gateway_type = :authorize_net

    assert_equal :credit_card_authorize_net_payment_profile_token, account.credit_card_stored_attribute
  end

  test 'credit_card_stored? return true when credit_card_auth_code present for payment gateways different from authorize.net' do
    provider_account = FactoryBot.create(:simple_provider)
    account = FactoryBot.create(:simple_account, :provider_account => provider_account)
    provider_account.payment_gateway_type = :braintree_blue
    account.credit_card_auth_code = 'code'
    assert account.credit_card_stored?
  end

  test 'credit_card_authorize_net_profile_stored? true if account has an auth.net profile ' do
    provider_account = FactoryBot.create(:simple_provider)
    account = FactoryBot.create(:simple_account, :provider_account => provider_account)
    provider_account.payment_gateway_type = :authorize_net
    account.credit_card_auth_code = 'profile'
    account.credit_card_authorize_net_payment_profile_token = nil
    assert account.credit_card_authorize_net_profile_stored?
  end

  test 'credit_card_authorize_net_profile_stored? false for new customers' do
    provider_account = FactoryBot.create(:simple_provider)
    account = FactoryBot.create(:simple_account, :provider_account => provider_account)
    provider_account.payment_gateway_type = :authorize_net
    account.credit_card_auth_code = 'profile'
    account.credit_card_authorize_net_payment_profile_token = nil
    assert account.credit_card_authorize_net_profile_stored?
  end

  test 'remove cc info after delete_cc_details' do
    provider_account = FactoryBot.create(:simple_provider)
    account = FactoryBot.create(:simple_account, :provider_account => provider_account)
    account.credit_card_auth_code = 'code'
    assert account.credit_card_stored?
    account.delete_cc_details

    account.reload
    account.save!
    refute account.credit_card_stored?
  end

  test 'unstore credit card is callable from outside the class' do
    provider = FactoryBot.create(:simple_account, :payment_gateway_type => :bogus, :credit_card_auth_code => "fdsa",
                       :credit_card_expires_on => Date.new(2020, 4, 2), :credit_card_partial_number => "0989")

    assert_nothing_raised do
      provider.unstore_credit_card!
    end

    assert_nil provider.credit_card_auth_code
    assert_equal Time.zone.today.change(:day => 1), provider.credit_card_expires_on_with_default
    assert_nil provider.credit_card_partial_number
  end

  test '#credit_card_editable? returns false for master account' do
    refute master_account.credit_card_editable?
  end

  test "only validates payment_detail_conditions when updating payment detail" do
    account = Account.new(:org_name => 'ACME', :payment_detail_conditions => false)
    assert account.save!, "Account should save when account is new"

    account = Account.create!(:org_name => 'ACME')
    assert account.update_attributes(:org_name => 'New ACME', :payment_detail_conditions => false), "Account should update when not updating credit card details"

    account = Account.create!(:org_name => 'ACME')
    account.updating_payment_detail = true
    assert !account.update_attributes(:org_name => 'New ACME', :payment_detail_conditions => false), "Account shouldn't update when updating credit card details without accepting conditions"
  end

  test '#credit_card_exires_on_with_default' do
    Timecop.freeze(Time.utc(2017,8,30))
    account = FactoryBot.create(:simple_provider)

    assert_equal '2017-08-01', account.credit_card_expires_on_with_default.to_s
    assert_nil account.credit_card_expires_on
    Timecop.return
  end

  class CreditCardNeededTest < ActiveSupport::TestCase
    setup do
      @provider_account = FactoryBot.create(:provider_account,
                                         :billing_strategy => FactoryBot.create(:postpaid_billing, :charging_enabled => true))

      @buyer = FactoryBot.create :simple_buyer, :provider_account => @provider_account
      @paid_plan = FactoryBot.create :service_plan, :issuer => @provider_account.default_service, :cost_per_month => 10
      @buyer.buy! @paid_plan
    end

    test 'Provider requires credit card. Buyer has paid plans, and monthly charging enabled' do
      assert @provider_account.billing_strategy.try!(:needs_credit_card?)
      assert @buyer.settings.monthly_charging_enabled?

      assert @buyer.credit_card_needed?
    end

    test 'be false if provider does not require credit card' do
      @provider_account.billing_strategy.destroy
      @provider_account.reload

      assert !@buyer.credit_card_needed?
    end

    test 'be false if buyer has no paid plans' do
      @paid_plan.contracts.destroy_all

      assert !@buyer.credit_card_needed?
    end

    test 'be false if buyer has monthly_charging disabled' do
      @buyer.settings.toggle! :monthly_charging_enabled

      assert !@buyer.settings.monthly_charging_enabled?
      assert !@buyer.credit_card_needed?
    end
  end

  class CallbacksTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    def test_add_credit_card_details
      account = FactoryBot.create(:provider_account)
      account.credit_card_auth_code = account.credit_card_partial_number = '0000'
      account.credit_card_expires_on = Date.new(2017, 11, 1)

      ThreeScale::Analytics.expects(:track_account)
        .with(account,
              'Credit Card Changed',
              valid_previously: false,
              valid_now: true,
              expired_on: nil,
              expires_on: Date.new(2017, 11, 1)
        )

      assert account.save!
    end

    def test_remove_credit_card_details
      account = FactoryBot.create(:provider_account,
                                   credit_card_auth_code: '0000',
                                   credit_card_partial_number: '0000',
                                   credit_card_expires_on: Date.new(2017, 11, 1))
      account.delete_cc_details

      ThreeScale::Analytics.expects(:track_account)
        .with(account,
              'Credit Card Changed',
              valid_previously: true,
              valid_now: false,
              expires_on: nil,
              expired_on: Date.new(2017, 11, 1)
        )

      account.save!
    end

    def test_events_without_change
      account = FactoryBot.create(:provider_account)

      account.org_name += 'foobar'
      ThreeScale::Analytics.expects(:track_account).never

      account.save!
    end
  end
end
