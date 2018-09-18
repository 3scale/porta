require 'test_helper'

class Csv::ApplicationsExporterTest < ActiveSupport::TestCase

  def belongs_to_provider(line, provider)
    line["#{provider.org_name}/#{provider.domain} "]
  end

  def correct_objects(line, what)
    line["All #{what} / All time"]
  end

  def correct_date(line, date)
    line["#{date}"]
  end

  def create_buyer_for(provider, date = Time.utc(2011,1,1))
    Timecop.freeze(date) do
      buyer = Factory.create(:buyer_account,
                             provider_account: provider)

      plan = provider.account_plans.default
      plan.update_column(:name, 'Plan of the Escape')
      plan.create_contract_with(buyer)
      buyer
    end
  end

  def create_app_for(buyer, date = Time.utc(2011,1,1))
    Timecop.freeze(date) do
      service = Factory :service, :account => buyer.provider_account

      plan = Factory :application_plan, :issuer => service, :name => 'Plan of the Escape'
      cinstance = plan.create_contract_with(buyer)
      cinstance.extra_fields = { "fruit" => "Apple" }
      cinstance.save!
    end
  end

  def setup
    @provider = Factory :provider_account, org_name: 'Generalitat', domain: 'gen.example.com'
    Factory(:fields_definition, :account => @provider, :target => "Cinstance",
            name: "fruit",
            choices: ["Orange", "Apple", "Banana"])
    @provider.reload
    @buyer1 = create_buyer_for(@provider)
    @buyer1.update_attributes(org_name: "MoltbeCat", telephone_number: "+34 902 311 2131")
    @buyer1.admins.first.update_attributes(username: 'akira', email: 'akira@moltbe.cat', :first_name => "Akira", :last_name => "Kurosawa")
    create_app_for(@buyer1)
    create_app_for(@buyer1, Time.now.utc)
  end

  test 'to_csv' do
    Timecop.freeze(Time.utc(2011,1,1)) do
      cinstance = @provider.services[1].cinstances.first!
      cinstance.update_attributes(first_daily_traffic_at: '2016-03-03 00:00:00 UTC')
      exporter = Csv::ApplicationsExporter.new(@provider, {data: 'applications'})
      lines = exporter.to_csv.lines.to_a

      assert belongs_to_provider(lines[0], @provider), "belongs to provider"
      assert correct_objects(lines[0], "Applications")
      assert correct_date(lines[0], "(generated 2011-01-01 00:00:00 UTC)")

      # assert_equal "Generalitat/gen.example.com - All Applications / All time (generated 2011-01-01 00:00:00 UTC)\n", lines[0]

      assert_equal "\n", lines[1]
      assert_equal "Application ID,Application Name,Plan,Account Name,Service Name,Application State,Application Created At,Traffic On,Paid?,Intentions,Username,First Name,Last Name,User Specific Data,Organization Name,Legal Address,Country,Country Code,Email,Telephone Number,Registered\n", lines[2]
      assert_equal "#{cinstance.id},MoltbeCat's App,Plan of the Escape,#{cinstance.account.name},#{cinstance.issuer.name},live,2011-01-01 00:00:00 UTC,2016-03-03 00:00:00 UTC,free,Default application created on signup.,akira,Akira,Kurosawa,\"{\"\"fruit\"\":\"\"Apple\"\"}\",MoltbeCat,Perdido Street 123,Spain,ES,akira@moltbe.cat,+34 902 311 2131,2011-01-01 00:00:00 UTC\n", lines[3]

      assert_equal @provider.provided_cinstances.count, lines.length - 3
      assert_equal 2, lines.length - 3
    end
  end

  test 'today' do
    exporter = Csv::ApplicationsExporter.new(@provider, period: 'today')
    lines = exporter.to_csv.lines.to_a
    assert_equal 1, lines.length - 3
  end

  test 'week' do
    exporter = Csv::ApplicationsExporter.new(@provider, period: 'this_week')
    lines = exporter.to_csv.lines.to_a
    assert_equal 1, lines.length - 3
  end

  test 'month' do
    create_app_for(@buyer1, Time.now.beginning_of_month)
    exporter = Csv::ApplicationsExporter.new(@provider, period: 'this_month')
    lines = exporter.to_csv.lines.to_a
    assert_equal 2, lines.length - 3
  end

  test 'this year' do
    create_app_for(@buyer1, Time.now.beginning_of_month)
    exporter = Csv::ApplicationsExporter.new(@provider, period: 'this_month')
    lines = exporter.to_csv.lines.to_a
    assert_equal 2, lines.length - 3
  end

  test 'last year' do
    create_app_for(@buyer1, 1.year.ago.utc)
    exporter = Csv::ApplicationsExporter.new(@provider, period: 'this_month')
    lines = exporter.to_csv.lines.to_a
    assert_equal 1, lines.length - 3
  end

end
