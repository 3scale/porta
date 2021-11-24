# frozen_string_literal: true

require 'test_helper'

class Finance::ChargingInvoiceStatesTest < ActionDispatch::IntegrationTest
  class UnpaidTest < Finance::ChargingInvoiceStatesTest
    setup do
      @invoice = FactoryBot.create(:invoice,
                                   :period => Month.new(Time.zone.local(1984, 1, 1)))

      @invoice.stubs(:cost).returns(100.to_has_money('EUR'))
      @invoice.issue_and_pay_if_free!
      @invoice.mark_as_unpaid!
    end

    test 'charge the buyer' do
      @invoice.buyer_account.stubs(:charge!).with(any_parameters).returns(true)
      @invoice.charge!
      assert @invoice.paid?, 'Should be paid after successful charge'
    end

    test 'be markable as paid' do
      @invoice.pay!
      assert @invoice.paid?
    end
  end

  class ChargingProviderTest < Finance::ChargingInvoiceStatesTest
    setup do
      @master = master_account
      @provider =  FactoryBot.create(:provider_account)
      @invoice = FactoryBot.create(:invoice,
                                   provider_account: @master,
                                   buyer_account: @provider,
                                   period:  Month.new(Time.zone.local(1984, 1, 1)))

      @invoice.stubs(:cost).returns(100.to_has_money('EUR'))
      @invoice.issue_and_pay_if_free!
      @invoice.mark_as_unpaid!
    end

    test 'charge the provider' do
      @invoice.buyer_account.stubs(:charge!).with(any_parameters).returns(true)

      @invoice.buyer_account.bought_plan.update!(name: 'Paid', cost_per_month: 100)

      ThreeScale::Analytics.expects(:track).with(@provider.first_admin!, 'Charged Invoice',
                                                 {plan: 'Paid', period: 'January 01, 1984 - January 31, 1984', revenue: 100.0})

      @invoice.charge!
      assert @invoice.paid?, 'Should be paid after successful charge'
    end
  end
end
