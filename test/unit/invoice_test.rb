require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  fixtures :countries

  should belong_to :buyer_account
  should belong_to :provider_account
  should validate_presence_of :provider_account
  should validate_presence_of :buyer_account

  should have_many :line_items
  should have_many :payment_transactions
  should have_attached_file :pdf

  def buyer_vat_rate(vat_rate)
    @invoice.buyer.update_attribute(:vat_rate, vat_rate)
    @invoice.reload
  end

  def setup
    Timecop.return
    @provider = FactoryGirl.create(:simple_provider)
    @buyer = FactoryGirl.create(:simple_buyer, provider_account: @provider)

    @invoice = FactoryGirl.create(:invoice,
                                  period: Month.new(Time.zone.local(1984, 1, 1)),
                                  provider_account: @provider,
                                  buyer_account: @buyer,
                                  friendly_id: '0000-00-00000001')
    @billing = Finance::BackgroundBilling.new(@invoice)
  end

  test 'LogEntry is created after the invoice is created' do
    assert_difference LogEntry.method(:count) do
      Invoice.create(period: Month.new(Time.zone.local(2002, 10, 10)),
                     provider_account: @provider,
                     buyer_account: @buyer,
                     friendly_id: '0000-00-00000001')
    end
    log_entry = LogEntry.last
    assert_equal :info, log_entry.level
    assert_equal @provider.id, log_entry.provider_id
    assert_equal @buyer.id, log_entry.buyer_id
  end

  test 'be exportable to XML' do
    # TODO: some heavier testing and selecting needed
    assert_not_nil @invoice.to_xml
  end

  test 'have period when loaded' do
    @invoice.reload
    assert_instance_of Month, @invoice.period
  end

  test 'have period, period_start and period_end' do
    @invoice.update_attribute(:period, Month.new(Time.utc(1986, 4, 23)))
    assert_equal Time.utc(1986, 4, 1).to_date, @invoice.period_start
    assert_equal Time.utc(1986, 4, 1).end_of_month.to_date, @invoice.period_end
  end

  test 'have no due_on and issued_on date on creation' do
    assert_nil @invoice.due_on
    assert_nil @invoice.issued_on
    assert_nil @invoice.finalized_at
  end

  test 'finalize state' do
    time = Time.zone.now
    Timecop.freeze(time) { @invoice.finalize! }

    assert_equal time.round, @invoice.finalized_at.round
    assert @invoice.finalized?
  end

  test 'finalized_before ignores cancelled invoices' do
    time = Time.now.utc
    assert Invoice.finalized_before(time).empty?

    cancelled = FactoryGirl.create(:invoice, provider_account: @provider, buyer_account: @buyer)
    finalized = FactoryGirl.create(:invoice, provider_account: @provider, buyer_account: @buyer)

    Timecop.freeze(time) { [finalized, cancelled].each(&:finalize!) }
    cancelled.cancel!

    assert Invoice.finalized_before(time - 1.hour).empty?
    assert_equal 1, Invoice.finalized_before(time).count
    assert_equal finalized, Invoice.finalized_before(time).first
  end

  test 'fail on incorrect friendly_id format' do
    @invoice.friendly_id = "#{Time.now.year}-0000000a"

    refute @invoice.valid?
    refute @invoice.errors[:friendly_id].empty?
  end

  test 'skips validation of default friendly_id' do
    invoice = FactoryGirl.build(:invoice, period: Month.new(Time.zone.local(1984, 1, 1)),
                                          provider_account: @provider,
                                          buyer_account: @buyer)

    assert_equal Invoice.columns_hash['friendly_id'].default, invoice.friendly_id
    assert invoice.valid?
    assert invoice.errors[:friendly_id].empty?
  end

  test 'keeps custom friendly_id if passed' do
    invoice = FactoryGirl.create(:invoice, period: Month.new(Time.zone.local(2015, 3, 1)),
                                           provider_account: @provider,
                                           buyer_account: @buyer,
                                           friendly_id: '2015-00000008').reload

    assert_equal '2015-00000008', invoice.friendly_id
  end

  class AutoFriendlyIdTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    def setup
      @provider = FactoryGirl.create(:simple_provider)
      @buyer = FactoryGirl.create(:simple_buyer, provider_account: @provider)
    end

    test 'gets sequential friendly_ids after saved' do
      @provider.billing_strategy = FactoryGirl.create(:prepaid_billing, numbering_period: 'monthly')
      @provider.billing_strategy.create_invoice_counter('1984-01')

      invoice = FactoryGirl.build(:invoice, period: Month.new(Time.zone.local(1984, 1, 1)),
                                            provider_account: @provider,
                                            buyer_account: @buyer)

      assert_equal Invoice.columns_hash['friendly_id'].default, invoice.friendly_id

      invoice.save!

      assert_equal '1984-01-00000001', invoice.friendly_id

      subsequent_invoice = FactoryGirl.create(:invoice, period: Month.new(Time.zone.local(1984, 1, 1)),
                                                        provider_account: @provider,
                                                        buyer_account: @buyer)

      assert_equal '1984-01-00000002', subsequent_invoice.friendly_id
    end
  end

  [:open, :finalized, :pending, :unpaid, :failed].each do |state|
    test "be cancellable when #{state}" do
      @invoice.cancel!
      assert_equal 'cancelled', @invoice.state
    end
  end

  test 'invoice is editable only when open or finalized' do
    assert @invoice.editable?

    @invoice.finalize!
    assert @invoice.editable?

    assert @invoice.issue_and_pay_if_free!
    assert(!@invoice.editable?)
  end

  test 'be due and paid if issued with 0 cost' do
    @invoice.stubs(:cost).returns(0.to_has_money('EUR'))
    @invoice.finalize!

    Timecop.freeze(@now = Time.zone.now) { @invoice.issue_and_pay_if_free! }

    assert_equal @now.utc.to_date, @invoice.issued_on
    assert_equal @now.round, @invoice.paid_at.round
    assert_equal 'paid', @invoice.state
  end

  test 'have PDF after issued' do
    @invoice.stubs(:cost).returns(0.to_has_money('EUR'))
    @invoice.issue_and_pay_if_free!
    assert @invoice.pdf.file?, 'Test have PDF when issued'
  end

  test 'issuing with non-zero cost sets meaningful dates' do
    @invoice.stubs(:cost).returns(100.to_has_money('EUR'))
    @invoice.finalize!

    Timecop.freeze(@now = Time.zone.now) { @invoice.issue_and_pay_if_free! }

    assert_equal @now.utc.to_date, @invoice.issued_on
    assert_not_nil @invoice.due_on
    assert_equal 'pending', @invoice.state
  end

  test 'have due_on after issued_on' do
    @invoice.stubs(:cost).returns(100.to_has_money('EUR'))
    Timecop.freeze(@now = Time.zone.now) { @invoice.issue_and_pay_if_free! }
    assert @invoice.issued_on < @invoice.due_on
  end

  test '#to_param returns id' do
    invoice = FactoryGirl.create(:invoice, created_at: Time.utc(1986, 4, 23),
                                           provider_account: @provider,
                                           buyer_account: @buyer)
    assert_equal invoice.id.to_s, invoice.to_param
  end

  test '#to returns by presence billing_address and legal_address' do
    assert_equal 'Perdido Street 123', @invoice.to.line1
    @invoice.buyer.update_attribute :org_legaladdress, nil
    @invoice.buyer.reload
    assert_equal 'Booked 2', @invoice.to.line1
  end

  test 'have cost that is sum of line items plus VAT' do
    invoice = FactoryGirl.create(:invoice, provider_account: @provider, buyer_account: @buyer)
    assert_equal 0, invoice.cost

    invoice.line_items.build(cost: 100)
    invoice.line_items.build(cost: 900)
    invoice.save!
    assert_equal 1000, invoice.cost

    # take vat_rate from buyer
    assert_equal 'open', invoice.state
    invoice.buyer.update_attribute(:vat_rate, 12.3)
    assert_equal 1123, invoice.reload.cost

    # pending should take the frozen vat_rate
    invoice.issue_and_pay_if_free!
    invoice.buyer_account.update_attribute(:vat_rate, 333)

    assert_equal 'pending', invoice.state
    invoice.buyer_account.vat_rate = 12.3
    assert_equal 1123, invoice.cost
  end

  test 'transitions from state' do
    invoice = FactoryGirl.create(:invoice, provider_account: @provider, buyer_account: @buyer)

    transition = invoice.next_transition_from_state('finalized')
    assert_equal :finalize, transition.event

    invoice.finalize
    assert_nil invoice.next_transition_from_state('finalized')

    transition = invoice.next_transition_from_state('cancelled')
    assert_equal :cancel, transition.event
  end

  # TODO: remove - use open? instead
  test 'have current? method' do
    Timecop.freeze do
      invoice_one = FactoryGirl.create(:invoice, period: Month.new(Time.zone.local(1984, 1, 1)), provider_account: @provider, buyer_account: @buyer)
      invoice_two = FactoryGirl.create(:invoice, provider_account: @provider, buyer_account: @buyer)

      refute invoice_one.current?
      assert invoice_two.current?
    end
  end

  test "invoice is 'chargeable' if it is pending or unpaid, due and it wasn't charged in 3 days or more" do
    params = { provider_account: @provider, buyer_account: @buyer }
    now = Time.zone.now

    # chargeable invoices
    FactoryGirl.create(:invoice, params.merge(state: 'unpaid', due_on: now))
    FactoryGirl.create(:invoice, params.merge(state: 'pending', due_on: now))

    # not chargeable decoys
    FactoryGirl.create(:invoice, params.merge(state: 'pending', due_on: now, last_charging_retry: now - 2.days))
    FactoryGirl.create(:invoice, params.merge(state: 'pending', due_on: now + 1.day))

    assert_equal 2, Invoice.chargeable(now).count
  end

  def build_invoice(attributes = {})
    invoice_attributes = { provider_account: @provider,
                           buyer_account: @buyer,
                           due_on: Time.zone.now,
                           state: 'pending' }
    cost = ThreeScale::Money.new(attributes.delete(:cost) || 100.0, 'EUR')
    invoice = FactoryGirl.build(:invoice, invoice_attributes.merge(attributes))
    invoice.stubs(cost: cost)
    invoice
  end

  test 'chargeable?' do
    invoice = build_invoice(state: 'paid')
    refute invoice.chargeable?
    assert_equal 'already paid', invoice.reason_cannot_charge

    invoice = build_invoice(provider_account: nil)
    refute invoice.chargeable?
    assert_equal 'missing provider', invoice.reason_cannot_charge

    unconfigured_provider = FactoryGirl.create(:simple_provider)
    unconfigured_provider.stubs(payment_gateway_configured?: false)
    invoice = build_invoice(provider_account: unconfigured_provider)
    refute invoice.chargeable?
    assert_equal 'missing payment gateway setting', invoice.reason_cannot_charge

    invoice = build_invoice(cost: 0.0)
    refute invoice.chargeable?
    assert_equal 'non-chargeable amount', invoice.reason_cannot_charge

    invoice = build_invoice(cost: -1.50)
    refute invoice.chargeable?
    assert_equal 'non-chargeable amount', invoice.reason_cannot_charge

    not_paying_monthly_buyer = FactoryGirl.create(:simple_buyer, provider_account: @provider)
    not_paying_monthly_buyer.stubs(paying_monthly?: false)
    invoice = build_invoice(buyer_account: not_paying_monthly_buyer)
    refute invoice.chargeable?
    assert_equal 'buyer not paying monthly', invoice.reason_cannot_charge

    assert build_invoice.chargeable?
  end

  test 'charge! should raise if cancelled or paid' do
    @invoice.cancel!
    assert_raises(Invoice::InvalidInvoiceStateException) { @invoice.charge! }

    @invoice.update_attribute(:state, 'paid')
    assert_raises(Invoice::InvalidInvoiceStateException) { @invoice.charge! }
  end

  def setup_1964_and_2009_invoices
    @invoice_one = FactoryGirl.create(:invoice,
                                      buyer_account: @buyer,
                                      provider_account: @provider,
                                      period: Month.new(Time.utc(2009, 6, 1)))

    @invoice_two = FactoryGirl.create(:invoice,
                                      provider_account: @provider,
                                      buyer_account: @buyer,
                                      period: Month.new(Time.utc(1964, 10, 1)))
  end

  private :setup_1964_and_2009_invoices

  test 'find only "old ones" with #before scope' do
    setup_1964_and_2009_invoices
    assert_equal 0, Invoice.before(Time.utc(1964, 10, 2)).count
  end

  test 'find_by_month' do
    setup_1964_and_2009_invoices
    assert_equal @invoice_one, Invoice.find_by_month('2009-06')
    assert_equal @invoice_two, Invoice.find_by_month('1964-10')
  end

  test 'opened_by_buyer' do
    setup_1964_and_2009_invoices
    assert_equal @invoice_one, Invoice.opened_by_buyer(@buyer)
  end

  test 'currency is frozen after issuing' do
    before = @invoice.provider.currency

    @invoice.issue_and_pay_if_free!
    @invoice.provider.stubs(:currency).returns('XXX')

    assert_equal before, @invoice.currency
  end

  # Regression test for:
  # `issued_on` and `due_on` not in PDF (#2381)
  test 'issued_on and due_on is present while generating PDF' do
    @invoice.expects(:generate_pdf!).with do
      @data_for_pdf = [@invoice.issued_on, @invoice.due_on]
    end

    @invoice.issue_and_pay_if_free!

    assert_not_nil @data_for_pdf[0]
    assert_not_nil @data_for_pdf[1]
  end

  test 'vat_rate and address is frozen after issuing' do
    spain = Country.find_by_code!('ES')
    usa = Country.find_by_code!('US')

    buyer = @invoice.buyer

    buyer.country = spain
    buyer.vat_rate = 25
    buyer.save!

    # make sure the values are dynamic when 'open'
    @invoice.reload

    assert_equal 'Spain', @invoice.to.country
    assert_equal 'Barcelona', @invoice.to.city
    assert_equal 25, @invoice.vat_rate

    # that should freeze all
    @invoice.issue_and_pay_if_free!
    buyer.city = 'BCN'
    buyer.country = usa
    buyer.vat_rate = 99
    buyer.save!

    # make sure invoice remains the same
    @invoice.reload
    assert_equal 'Spain', @invoice.to.country
    assert_equal 'Barcelona', @invoice.to.city
  end

  test 'unresolved invoices' do
    Invoice.delete_all
    [:open, :finalized, :pending, :unpaid, :failed, :cancelled, :paid].each do |state|
      FactoryGirl.create(:invoice, state: state, provider_account: @provider, buyer_account: @buyer)
    end

    assert_equal 4, @buyer.invoices.unresolved.count
  end

  test 'exact cost without vat' do
    buyer_vat_rate(10)
    item = { name: 'Fake', cost: 1.233, description: 'really', quantity: 1 }
    @billing.create_line_item!(item)
    item = { name: 'Fake', cost: 0.0001, description: 'really2', quantity: 1 }
    @billing.create_line_item!(item)
    assert_equal 1.2331, @invoice.exact_cost_without_vat
  end

  test 'charge cost without vat' do
    buyer_vat_rate(10)
    item = { name: 'Fake', cost: 1.233, description: 'really', quantity: 1 }
    @billing.create_line_item!(item)
    item = { name: 'Fake', cost: 0.0001, description: 'really2', quantity: 1 }
    @billing.create_line_item!(item)
    assert_equal 1.23, @invoice.charge_cost_without_vat
  end

  test 'exact vat' do
    buyer_vat_rate(10)
    item = { name: 'Fake', cost: 1.233, description: 'really', quantity: 1 }
    @billing.create_line_item!(item)
    item = { name: 'Fake', cost: 0.0001, description: 'really2', quantity: 1 }
    @billing.create_line_item!(item)
    assert_equal 0.12331, @invoice.vat_amount
  end

  test 'VAT cost' do
    buyer_vat_rate(10)
    item = { name: 'Fake', cost: 1.233, description: 'really', quantity: 1 }
    @billing.create_line_item!(item)
    item = { name: 'Fake', cost: 0.0001, description: 'really2', quantity: 1 }
    @billing.create_line_item!(item)
    assert_equal 0.12, @invoice.charge_cost_vat_amount
  end

  test 'charged cost' do
    buyer_vat_rate(10)
    item = { name: 'Fake', cost: 1.233, description: 'really', quantity: 1 }
    @billing.create_line_item!(item)
    item = { name: 'Fake', cost: 0.0001, description: 'really2', quantity: 1 }
    @billing.create_line_item!(item)
    assert_equal((0.12 + 1.23), @invoice.charge_cost)
  end

  test '#charge! is successful' do
    @buyer.expects(:charge!).returns(true)
    @provider.stubs(:payment_gateway_configured?).returns(true)
    @billing.create_line_item!(name: 'Fake', cost: 1.233, description: 'really', quantity: 1)
    @invoice.update_attribute(:state, 'pending')

    assert @invoice.charge!, 'Invoice should charge!'
  end

  test '#charge! failed if provider payment_gateway is unconfigured' do
    @buyer.expects(:charge!).never
    @provider.stubs(:payment_gateway_unconfigured?).returns(true)
    @invoice.update_attribute(:state, 'pending')

    refute @invoice.charge!, 'Invoice should not charge!'
  end

  test '#buyer_field_label' do
    @buyer.expects(:field_label).with('vat_rate')
    @invoice.buyer_field_label('vat_rate')

    @invoice.stubs(buyer_account: nil)
    assert_equal 'Vat rate', @invoice.buyer_field_label('vat_rate')
  end

  test '#check_editable_line_items doesn\'t raise any error when the state is \'open\'' do
    assert_nothing_raised do
      @invoice.update_attribute(:state, 'open')
      @invoice.check_editable_line_items
    end
  end

  test '#check_editable_line_items raises InvalidInvoiceStateException when the state is not \'editable?\'' do
    Invoice.state_machine.states.each do |state|
      state_name = state.name
      if [:open, :finalized].include?(state_name)
          @invoice.update_attribute(:state, state_name.to_s)
          @invoice.check_editable_line_items
      else
        assert_raise Invoice::InvalidInvoiceStateException do
          @invoice.update_attribute(:state, state_name.to_s)
          @invoice.check_editable_line_items
        end
      end
    end
  end

  test 'creation_type is by default :manual' do
    invoice = @buyer.invoices.create! period: Month.new(Time.utc(2009, 6, 1)),
                                      provider_account: @provider,
                                      friendly_id: '0000-00-00000001'
    assert_equal 'manual', invoice.creation_type
  end

  class CounterUpdateTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    def setup
      @provider = FactoryGirl.create(:simple_provider)
      @buyer = FactoryGirl.create(:simple_buyer, provider_account: @provider)

      invoice_period = Month.new(Time.zone.local(2018, 1, 1))

      @provider.billing_strategy = FactoryGirl.create(:prepaid_billing, numbering_period: 'yearly')
      @provider.billing_strategy.create_invoice_counter(invoice_period)

      @invoice = FactoryGirl.create(:invoice, period: invoice_period,
                                              provider_account: @provider,
                                              buyer_account: @buyer).reload
    end

    test 'updates counter when friendly id changes' do
      assert_equal 1, @invoice.counter.invoice_count

      @invoice.friendly_id = "#{@invoice.id_prefix}-00000013"
      @invoice.save

      assert_equal 13, @invoice.counter.invoice_count
    end

    test 'jumps the counter when friendly id jumps' do
      invoice = FactoryGirl.create(:invoice,
                                    period: Month.new(Time.zone.local(2018, 1, 1)),
                                    provider_account: @provider,
                                    buyer_account: @buyer,
                                    friendly_id: '2018-00000008').reload

      assert_equal 8, invoice.counter.invoice_count

      other_invoice = FactoryGirl.create(:invoice, period: Month.new(Time.zone.local(2018, 1, 1)),
                                                   provider_account: @provider,
                                                   buyer_account: @buyer).reload

      assert_equal 9, other_invoice.counter.invoice_count
      assert_equal '2018-00000009', other_invoice.friendly_id
    end

    test 'creates a new counter if new prefix' do
      assert_equal 1, @invoice.counter.invoice_count

      @invoice.friendly_id = '2019-00000006'
      assert_difference InvoiceCounter.method(:count) do
        @invoice.save
      end

      assert_equal '2019', @invoice.counter.invoice_prefix
      assert_equal 6, @invoice.counter.invoice_count
    end
  end
end
