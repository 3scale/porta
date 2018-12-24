require 'test_helper'

class Finance::VariableCostCalculationTest < ActiveSupport::TestCase
  # Note: It would be cleaner to stub the cinstance and focus only on the module itself, but
  # I wanted to avoid getting drowned in a quagmire of mocks...

  def setup
    @cinstance  = FactoryBot.create(:cinstance)
    @metric_one = @cinstance.service.metrics.hits
    @metric_two = FactoryBot.create(:metric, :service => @cinstance.service)

    @stats = stub('stats')
    Stats::Client.stubs(:new).with(@cinstance).returns(@stats)

    @cinstance.reload # Reset association cache

    @plan = @cinstance.plan
  end

  # http://i2.kym-cdn.com/photos/images/original/000/234/786/bf7.gif
  test "variable line items are created" do
    Timecop.travel(Date.today.year + 1, 11, 04) do

      billing_strategy = @cinstance.provider_account.billing_strategy = FactoryBot.create(:postpaid_billing)

      period = Date.today..Month.new(Time.zone.now).end
      @stats.stubs(:total).with(
        has_entries(period: period.begin.to_time..period.end.to_time.end_of_day, metric: @metric_one)
      ).returns(1000)

      @plan.pricing_rules.create! metric: @metric_one, cost_per_unit: 0.1

      invoice = billing_strategy.create_invoice! buyer_account: @cinstance.account
      @cinstance.bill_for_variable(period, invoice)

      assert_kind_of LineItem::VariableCost, invoice.line_items.first

    end
  end

  test '#calculate_variable_cost returns a hash of costs calculated from the pricing rules' do
    period = Month.current

    @stats.stubs(:total).with(
      has_entries(:period => period,
                  :metric => @metric_one)).returns(1000)

    @stats.stubs(:total).with(
      has_entries(:period => period,
                  :metric => @metric_two)).returns(2000)

    @plan.pricing_rules.create!(:metric => @metric_one, :cost_per_unit => 0.1)
    @plan.pricing_rules.create!(:metric => @metric_two, :cost_per_unit => 0.2)

    assert_equal({@metric_one => 100, @metric_two => 400},
                 @cinstance.calculate_variable_cost(period)[1])
  end

  test '#calculate_variable_cost does the calculations in the timezone of the provider' do
    @cinstance.provider_account.update_attribute(:timezone, 'Santiago')
    @plan.pricing_rules.create!(:metric => @metric_one, :cost_per_unit => 0.1)

    @stats.expects(:total).with(has_entry(:timezone => 'Santiago')).returns(0)
    @cinstance.calculate_variable_cost(Month.current)
  end

  test '#calculate_variable_cost returns empty hash if no pricing rules are defined' do
    @cinstance.plan.pricing_rules.destroy_all

    assert_equal({}, @cinstance.calculate_variable_cost(Month.current)[1])
  end

  test '#calculate_variable_cost returns hash of zeroes if no usage is collected' do
    period = Month.current

    @stats.stubs(:total).with(has_entries(:period => period)).returns(0)

    @plan.pricing_rules.create!(:metric => @metric_one, :cost_per_unit => 0.1)
    @plan.pricing_rules.create!(:metric => @metric_two, :cost_per_unit => 0.2)

    assert_equal({@metric_one => 0, @metric_two => 0},
                 @cinstance.calculate_variable_cost(period)[1])
  end
end
