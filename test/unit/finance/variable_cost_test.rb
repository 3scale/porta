require 'test_helper'

class Finance::VariableCostTest < ActiveSupport::TestCase

  test 'bill_variable_fee_for' do
    cinstance = Factory(:cinstance)
    fake_model = Factory(:provider_with_billing)
    period = Month.new(Time.now)
    invoice_proxy = Finance::InvoiceProxy.new(fake_model, period)

    metric = Factory(:metric)
    cinstance.stubs(:calculate_variable_cost).returns([{metric => 1},{metric => 10}])
    cinstance.send(:bill_variable_fee_for, period, invoice_proxy, cinstance.plan)

    line_item = LineItem.last
    assert_equal 'LineItem::VariableCost', line_item.type
    assert_equal metric, line_item.metric
    assert_equal metric.friendly_name, line_item.name
    assert_equal period.to_time_range.to_s, line_item.description
    assert_equal cinstance, line_item.contract
    assert_equal 1, line_item.quantity
  end
end
