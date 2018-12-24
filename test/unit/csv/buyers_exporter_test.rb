require 'test_helper'

class Csv::BuyersExporterTest < ActiveSupport::TestCase

  def create_buyer_for(provider, date = Time.utc(2011,1,1))
    Timecop.freeze(date) do
      buyer = FactoryBot.create(:buyer_account,
                             provider_account: provider)

      plan = provider.account_plans.default
      plan.update_column(:name, 'Plan of the Escape')
      plan.create_contract_with(buyer)
      buyer
    end
  end

  def setup
    @provider = FactoryBot.create(:provider_account, org_name: 'Generalitat', domain: 'generalitat.cat')
    @buyer = create_buyer_for(@provider)
    @buyer.admins.first.update_attributes(username: 'john_doe', email: 'john@my.company.it')
    @buyer.update_attributes(org_name: 'Eater')
    create_buyer_for(@provider, Time.now.utc)
  end

  test 'to_csv' do
    Timecop.freeze(Time.utc(2011,1,1)) do
      exporter = Csv::BuyersExporter.new(@provider)
      lines = exporter.to_csv.lines.to_a

      assert_equal %{Generalitat/generalitat.cat - All Objects / All time (generated 2011-01-01 00:00:00 UTC)\n}, lines[0]
      assert_equal "\n", lines[1]
      assert_equal "ID,Status,Group,Country,Plan Name,Signup Date,Number of Applications,Admin,E-mail,User Specific Data (Account),User Specific Data (Admin)\n", lines[2]
      assert_equal "#{@buyer.id},approved,Eater,Spain,Plan of the Escape,2011-01-01 00:00:00,#{@buyer.bought_cinstances.count},john_doe,john@my.company.it,{},{}\n", lines[3]
      assert_equal @provider.buyer_accounts.count, lines.length - 3
      assert_equal 2, lines.length - 3
    end
  end

  test 'today' do
    exporter = Csv::BuyersExporter.new(@provider, period: 'today')
    lines = exporter.to_csv.lines.to_a
    assert_equal 1, lines.length - 3
  end

  test 'week' do
    exporter = Csv::BuyersExporter.new(@provider, period: 'this_week')
    lines = exporter.to_csv.lines.to_a
    assert_equal 1, lines.length - 3
  end

  test 'month' do
    create_buyer_for(@provider, Time.now.beginning_of_month)
    exporter = Csv::BuyersExporter.new(@provider, period: 'this_month')
    lines = exporter.to_csv.lines.to_a
    assert_equal 2, lines.length - 3
  end

  test 'this year' do
    create_buyer_for(@provider, Time.now.beginning_of_month)
    exporter = Csv::BuyersExporter.new(@provider, period: 'this_month')
    lines = exporter.to_csv.lines.to_a
    assert_equal 2, lines.length - 3
  end

  test 'last year' do
    create_buyer_for(@provider, 1.year.ago.utc)
    exporter = Csv::BuyersExporter.new(@provider, period: 'this_month')
    lines = exporter.to_csv.lines.to_a
    assert_equal 1, lines.length - 3
  end
end
