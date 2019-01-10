require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

# REFACTOR: totally remove that and place Cinstance::Billing to some
# separate class/module
class Cinstance::BillingTest < ActiveSupport::TestCase

  context 'Cinstance::Billing' do
    setup do
        @end_of_november = Time.zone.local(2009,11,30)
        @first_of_december = Time.zone.local(2009,12,1)
        @november = Month.new(2009,11)
        @last_of_october = Time.zone.local(2009,9,30)

        @plan = FactoryBot.create(:application_plan, :name => 'FAKE')
        @plan.stubs(:cost_for_period).returns(42)
    end

    # context '#refund_fixed_cost' do
    #   setup do
    #     # TODO - remove too much implementation detail
    #     Finance::BillingOperations::stubs(:invoice_for_cinstance => (@invoice = mock))
    #   end

    #   should 'not bill if nothing is paid' do
    #    Finance::Billing.any_instance.expects(:create_line_item!).never
    #   end

    #   should 'bill if something is paid' do
    #     Finance::Billing.any_instance.expects(:create_line_item!).once
    #     cinstance = FactoryBot.create(:cinstance, :paid_until => @end_of_november, :plan => @plan)
    #     cinstance.refund_fixed_cost(@last_of_october)
    #   end
    # end

    context '#bill_for' do
      setup do
        @cinstance = FactoryBot.create(:cinstance, :paid_until => nil, :plan => @plan)
      end

      context 'with nothing to bill' do
        setup do
          @invoice = FactoryBot.create(:invoice)
        end

        should 'not bill [already paid]' do
          @cinstance.update_attribute( :paid_until, @end_of_november)
          @cinstance.bill_for(@november, @invoice)
          assert_equal 0, @invoice.line_items.count
        end

        should 'not bill [on trial]' do
          @cinstance.update_attribute( :paid_until, nil)
          @cinstance.stubs(:trial_period_expires_at).returns(@first_of_december)
          @cinstance.bill_for(@november, @invoice)
          assert_equal 0, @invoice.line_items.count
        end

        should 'not bill [zero cost]' do
          @plan.stubs(:cost_for_period).returns(0)
          @cinstance.bill_for(@november, @invoice)
          assert_equal 0, @invoice.line_items.count
        end
      end

      context 'with stuff to bill' do
        setup do
          Timecop.freeze(2010,1,1)
          @invoice = FactoryBot.create(:invoice)
        end

        should 'bill for setup fee just once' do
          @cinstance.update_attribute(:trial_period_expires_at, 1.day.ago)
          @cinstance.update_attribute(:setup_fee, 42)
          assert_difference @invoice.line_items.method(:count), 1 do
            2.times { @cinstance.bill_for(@november, @invoice) }
          end
        end

        should 'bill only unpaid part' do
          @cinstance.trial_period_expires_at = Time.zone.local(2009,11,9)
          @cinstance.paid_until = Time.zone.local(2009,11,10)

          billed_for = 'November 11, 2009 ( 0:00) - November 30, 2009 (23:59)'

          assert_difference @invoice.line_items.method(:count), 1 do
            @cinstance.bill_for(@november, @invoice)
          end
          assert_equal @end_of_november.to_date, @cinstance.reload.paid_until.to_date
        end

        should 'bill with correct info' do
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
  end
end
