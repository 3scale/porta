# frozen_string_literal: true

require 'test_helper'

# REFACTOR: totally remove that and place Cinstance::Billing to some
# separate class/module
class Cinstance::BillingTest < ActiveSupport::TestCase
  setup do
    @end_of_november = Time.zone.local(2009,11,30)
    @first_of_december = Time.zone.local(2009,12,1)
    @november = Month.new(2009,11)
    @last_of_october = Time.zone.local(2009,9,30)

    @plan = FactoryBot.create(:application_plan, :name => 'FAKE')
    @plan.stubs(:cost_for_period).returns(42)

    @cinstance = FactoryBot.create(:cinstance, :paid_until => nil, :plan => @plan)
  end

  pending_test '#refund_fixed_cost not bill if nothing is paid'
  pending_test '#refund_fixed_cost bill if something is paid'

  class NothingToBillTest < Cinstance::BillingTest
    setup do
      @invoice = FactoryBot.create(:invoice)
    end

    test 'should not bill [already paid]' do
      @cinstance.update(paid_until: @end_of_november)
      @cinstance.bill_for(@november, @invoice)
      assert_equal 0, @invoice.line_items.count
    end

    test 'should not bill [on trial]' do
      @cinstance.update(paid_until: nil)
      @cinstance.stubs(:trial_period_expires_at).returns(@first_of_december)
      @cinstance.bill_for(@november, @invoice)
      assert_equal 0, @invoice.line_items.count
    end

    test 'should not bill [zero cost]' do
      @plan.stubs(:cost_for_period).returns(0)
      @cinstance.bill_for(@november, @invoice)
      assert_equal 0, @invoice.line_items.count
    end
  end

  class StuffToBillTest < Cinstance::BillingTest
    setup do
      travel_to(Date.new(2010,1,1))
      @invoice = FactoryBot.create(:invoice)
    end

    test 'should bill for setup fee just once' do
      @cinstance.update_attribute(:trial_period_expires_at, 1.day.ago) # rubocop:disable Rails/SkipsModelValidations
      @cinstance.update_attribute(:setup_fee, 42) # rubocop:disable Rails/SkipsModelValidations
      assert_difference @invoice.line_items.method(:count), 1 do
        2.times { @cinstance.bill_for(@november, @invoice) }
      end
    end

    test 'should bill only unpaid part' do
      @cinstance.trial_period_expires_at = Time.zone.local(2009,11,9)
      @cinstance.paid_until = Time.zone.local(2009,11,10)

      assert_difference @invoice.line_items.method(:count), 1 do
        @cinstance.bill_for(@november, @invoice)
      end
      assert_equal @end_of_november.to_date, @cinstance.reload.paid_until.to_date
    end

    test 'should bill with correct info' do
      @cinstance.paid_until = nil
      # TODO: change from stub to attribute update
      @cinstance.stubs(:trial_period_expires_at => Time.zone.local(2009,1,1))
      @cinstance.bill_for(@november, @invoice)

      item = @invoice.line_items.first
      assert_equal @end_of_november.to_date, @cinstance.reload.paid_until.to_date
      assert_equal "Fixed fee ('FAKE')", item.name
      assert_equal 'November  1, 2009 ( 0:00) - November 30, 2009 (23:59)', item.description
      assert_equal 42, item.cost
    end
  end
end
