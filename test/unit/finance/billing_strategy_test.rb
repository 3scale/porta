require 'test_helper'

class Finance::BillingStrategyTest < ActiveSupport::TestCase
  include BillingResultsTestHelpers

  should belong_to :account
  should validate_presence_of :numbering_period

  def setup
    @provider = FactoryBot.create(:provider_with_billing)

    @bs = @provider.billing_strategy
    @bs.numbering_period = 'monthly'

    @buyer = FactoryBot.create(:buyer_account)
  end

  test 'add_cost' do
    contract = Contract.find(@provider.bought_cinstance.id)

    # TODO: calling a private method is not nice.
    @bs.send(:add_cost, contract, 'foo', 'bar', 10)

    assert line_item = LineItem::PlanCost.last, 'missing plan cost'

    assert_equal 'foo', line_item.name
    assert_equal 'bar', line_item.description
    assert_equal @provider.bought_cinstance, line_item.contract
  end

  test 'self.daily only a buyer of a provider, prepaid' do
    provider = FactoryBot.create(:simple_provider)
    FactoryBot.create(:prepaid_billing, account: provider)

    buyer = FactoryBot.create(:simple_buyer, provider_account: provider)
    FactoryBot.create(:simple_buyer, provider_account: provider)

    # Should run the method two time, one per buyer
    Finance::PrepaidBillingStrategy.any_instance.expects(:bill_expired_trials).twice
    Finance::BillingStrategy.daily(only: [provider.id])

    # Should run the method just one time because we are passing a specific
    # buyer_id
    Finance::PrepaidBillingStrategy.any_instance.expects(:bill_expired_trials).once
    Finance::BillingStrategy.daily(only: [provider.id], buyer_ids: [buyer.id])
  end

  test 'self.daily only a buyer of a provider, postpaid' do
    provider = FactoryBot.create(:simple_provider)
    FactoryBot.create(:postpaid_billing, account: provider)

    buyer = FactoryBot.create(:simple_buyer, provider_account: provider)
    FactoryBot.create(:simple_buyer, provider_account: provider)

    # Should run the method two time, one per buyer
    Finance::PostpaidBillingStrategy.any_instance.expects(:bill_expired_trials).twice
    Finance::BillingStrategy.daily(only: [provider.id])


    # Should run the method just one time because we are passing a specific
    # buyer_id
    Finance::PostpaidBillingStrategy.any_instance.expects(:bill_expired_trials).once
    Finance::BillingStrategy.daily(only: [provider.id], buyer_ids: [buyer.id])
  end

  test 'all providers but canaries' do
    canaries = FactoryBot.create_list(:provider_with_billing, 4).map(&:id)
    ThreeScale.config.expects(:billing_canaries).at_least_once.returns(canaries)

    all_but_canaries = Finance::BillingStrategy.all.pluck(:account_id) - canaries
    Finance::BillingStrategy.expects(:daily_async).with { |scope| scope.pluck(:account_id) == all_but_canaries }.returns(true)
    assert Finance::BillingStrategy.daily_rest
  end

  test 'canaries' do
    canaries = FactoryBot.create_list(:provider_with_billing, 4).map(&:id)
    ThreeScale.config.expects(:billing_canaries).at_least_once.returns(canaries)

    Finance::BillingStrategy.expects(:daily_async).with { |scope| scope.pluck(:account_id) == canaries }.returns(true)
    assert Finance::BillingStrategy.daily_canaries
  end

  test 'empty canaries' do
    2.times { FactoryBot.create(:prepaid_billing, :account => FactoryBot.create(:simple_provider)) }
    2.times { FactoryBot.create(:postpaid_billing, :account => FactoryBot.create(:simple_provider)) }
    ThreeScale.config.stubs(billing_canaries: nil)

    Finance::BillingStrategy.expects(:daily_async).never
    refute Finance::BillingStrategy.daily_canaries
  end

  test 'self.daily with providers excluded' do
    other_providers = FactoryBot.create_list(:simple_provider, 4)

    (0..1).each { |i| FactoryBot.create(:prepaid_billing, account: other_providers[i]) }
    (2..3).each { |i| FactoryBot.create(:postpaid_billing, account: other_providers[i]) }

    results = Finance::BillingStrategy.daily(exclude: [ @provider.id ])

    other_providers.each { |provider| assert results[provider.id] }
    refute results[@provider.id]

    assert results.successful?
  end

  test 'self.daily only with selected providers' do
    other_providers = FactoryBot.create_list(:simple_provider, 3)
    3.times { |i| FactoryBot.create(:prepaid_billing, account: other_providers[i]) }

    results = Finance::BillingStrategy.daily(only: [ @provider.id ])

    other_providers.each { |provider| refute results[provider.id] }
    assert results[@provider.id]

    assert results.successful?
  end

  test 'self.daily skips suspended accounts' do
    Finance::BillingStrategy.delete_all # don't really want the ones from setup

    suspended_provider = FactoryBot.create(:simple_provider, state: 'suspended')
    FactoryBot.create(:prepaid_billing, account: suspended_provider)

    results = Finance::BillingStrategy.daily

    assert results.skipped[suspended_provider.id]

    assert results.successful?
  end

  test 'currency cache returns string' do
    @bs.currency = 'USD'
    @bs.save
    assert_equal 'USD', ::Finance::BillingStrategy.account_currency(@provider.id)
  end

  test 'allow Finance::BillingStrategy::CURRENCIES but not blank currency' do
    @bs.currency = 'giberrish'
    refute @bs.valid?
    assert_equal 'invalid', @bs.errors[:currency].join('')

    Finance::BillingStrategy::CURRENCIES.each_value do |valid_currency|
      @bs.currency = valid_currency
      assert @bs.valid?
    end

    @bs.currency = nil
    refute @bs.valid?, 'must have currency'
    assert_equal 'invalid', @bs.errors[:currency].join('')
  end

  test 'default to highest number in month + 1' do
    create_two_invoices

    @invoice_three = @bs.create_invoice!(:buyer_account => @buyer,
                                         :period => Month.new(Time.zone.local(1984, 1, 1)))
    assert_equal '00000003', @invoice_three.friendly_id.split('-').last
  end

  test 'set correct friendly_id' do
    create_two_invoices

    last_year_invoice = @bs.create_invoice!(:buyer_account => @buyer,
                                         :period => Month.new(Time.zone.local(1983, 1, 1)))
    assert_equal '1983-01-00000001', last_year_invoice.friendly_id

    assert_equal '00000001', @invoice_one.friendly_id.split('-').last
    assert_equal '00000002', @invoice_two.friendly_id.split('-').last
  end

  test 'increment id by provider' do
    create_two_invoices

    second_provider = FactoryBot.create(:provider_with_billing)
    second_provider.billing_strategy.numbering_period = 'monthly'
    second_buyer = FactoryBot.create(:buyer_account)
    invoice_other_buyer = @bs.create_invoice!(:buyer_account => second_buyer,
                                              :period => Month.new(Time.zone.local(1984, 1, 1)))
    invoice_other_provider = second_provider.billing_strategy.create_invoice!(:buyer_account => @buyer,
                                                                              :period => Month.new(Time.zone.local(1984, 1, 1)))
    assert_equal '1984-01-00000003',  invoice_other_buyer.friendly_id
    assert_equal '1984-01-00000001',  invoice_other_provider.friendly_id
  end

  test 'yearly: default to highest number in the year + 1' do
    @bs.update_attribute(:numbering_period, 'yearly')

    one = @bs.create_invoice!(:buyer_account => @buyer, :period => Month.new(Time.zone.local(1984, 1, 1)))
    two = @bs.create_invoice!(:buyer_account => @buyer, :period => Month.new(Time.zone.local(1984, 1, 1)))
    other_month = @bs.create_invoice!(:buyer_account => @buyer, :period => Month.new(Time.zone.local(1984, 2, 2)))

    @provider.billing_strategy.update_attribute(:numbering_period, 'yearly')
    @invoice_three = @bs.create_invoice!(:buyer_account => @buyer,
                                         :period => Month.new(Time.zone.local(1984, 1, 1)))
    assert_equal '00000004', @invoice_three.friendly_id.split('-').last
  end

  test 'yearly: increment id by provider' do
    trap = @bs.create_invoice!( :buyer_account => @buyer, :period => Month.new(Time.zone.local(1984, 1, 1)))

    @bs.update_attribute(:numbering_period, 'yearly')

    one = @bs.create_invoice!(:buyer_account => @buyer, :period => Month.new(Time.zone.local(1984, 1, 1)))
    two = @bs.create_invoice!(:buyer_account => @buyer, :period => Month.new(Time.zone.local(1984, 1, 1)))
    other_month = @bs.create_invoice!(:buyer_account => @buyer, :period => Month.new(Time.zone.local(1984, 2, 2)))

    second_provider = FactoryBot.create(:provider_with_billing)
    second_provider.billing_strategy.update_attribute(:numbering_period, 'yearly')
    second_buyer = FactoryBot.create(:buyer_account)
    invoice_other_buyer = @bs.create_invoice!(:buyer_account => second_buyer, :period => Month.new(Time.zone.local(1984, 1, 1)))
    invoice_other_provider = second_provider.billing_strategy.create_invoice!(:buyer_account => @buyer, :period => Month.new(Time.zone.local(1984, 1, 1)))

    assert_equal '1984-00000004',  invoice_other_buyer.friendly_id
    assert_equal '1984-00000001',  invoice_other_provider.friendly_id
  end

  test 'notify_billing_finished' do
    @bs.notify_billing_finished(Time.utc(1984, 1, 1))
  end

  def test_create_invoices_to_review_event
    @bs.create_invoice!(buyer_account: @buyer, provider_account: @provider)
    LineItem.stubs(:sum_by_invoice_state).returns(100)

    Invoices::InvoicesToReviewEvent.expects(:create).once

    assert Finance::BillingStrategy.daily(
      only: [@provider.id],
      now:  DateTime.parse('2010-01-01 08:00')
    )
  end

  def test_create_expired_credit_card_provider_event
    now = DateTime.parse('2010-01-01 08:00')

    FactoryBot.create(:simple_buyer, provider_account: @provider,
      credit_card_expires_on: now.to_date + 10.days)

    Accounts::ExpiredCreditCardProviderEvent.expects(:create).once

    assert Finance::BillingStrategy.daily(only: [@provider.id], now: now)
  end

  def test_audit_prepaid_postpaid
    Finance::BillingStrategy.with_synchronous_auditing do
      @provider = FactoryBot.create(:provider_with_billing)
      strategy = @provider.billing_strategy
      assert 'postpaid', strategy.type
      strategy.type = 'prepaid'
      strategy.save!
      assert audit = strategy.audits.last
      assert audit.audited_changes.key? 'type'
    end
  end

  test 'does not notify billing success' do
    @bs.stubs(failed_buyers: [])
    results = mock_billing_success(Time.utc(2018, 3, 17, 18, 15), @provider)
    BillingMailer.expects(:billing_finished).never
    @bs.notify_billing_results(results)
  end

  test 'notifies billing failure' do
    buyer = FactoryBot.build_stubbed(:simple_buyer, provider_account: @provider)
    results = mock_billing_failure(Time.utc(2018, 3, 17, 18, 15), @provider, [buyer.id])
    BillingMailer.expects(:billing_finished).with(results).returns(mock(deliver_now: true))
    @bs.notify_billing_results(results)
  end

  class DailyBillingTest < ActiveSupport::TestCase
    setup do
      @providers = FactoryBot.create_list(:provider_with_billing, 3)
      @billing_strategies = Finance::BillingStrategy.where(account: @providers)
    end

    test 'self.daily_async sidekiq' do
      now = Time.utc(2017, 12, 1)

      BillingWorker.expects(:enqueue).with(@providers.first, now, nil).returns(true)
      BillingWorker.expects(:enqueue).with(@providers.second, now, nil).returns(true)
      BillingWorker.expects(:enqueue).with(@providers.third, now, nil).returns(true)

      Finance::BillingStrategy.daily_async(@billing_strategies, now: now)
    end
  end

  private

    def create_two_invoices
      @invoice_one = @bs.create_invoice!(:buyer_account => @buyer,
                                         :period => Month.new(Time.zone.local(1984, 1, 1)))

      @invoice_two = @bs.create_invoice!(:buyer_account => @buyer,
                                        :period => Month.new(Time.zone.local(1984, 1, 1)))
    end
end
