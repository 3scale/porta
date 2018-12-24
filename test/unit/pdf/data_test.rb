require 'test_helper'

class Pdf::DataTest < ActiveSupport::TestCase
  setup do
    # TODO: this is really terrible dependent test - remove as soon
    # as Stats::Deprecated is removed
    @provider_account = FactoryBot.create(:provider_account)
    @service = @provider_account.first_service!
    @plan = FactoryBot.create( :application_plan, :issuer => @service)
    @metric = @service.metrics.first
    # @buyer_account = FactoryBot.create(:buyer_account)
    # @cinstance = @buyer_account.buy!(@plan)

    # Stats::Base.storage.flushdb
    # Backend::Transaction.report!(:cinstance => @cinstance, :usage => {'hits' => 1}, :confirmed => true)
  end

  test 'fail without :period supplied' do
    assert_raises(ArgumentError) { Pdf::Data.new(@provider_account) }
  end

  test "generates traffic graph for week" do
    @data = Pdf::Data.new(@provider_account, @service, :period => :week)
    assert_not_nil @data.traffic_graph
  end

  test "generates traffic graph for day" do
    @data = Pdf::Data.new(@provider_account, @service, :period => :day)
    assert_not_nil @data.traffic_graph
  end

  test 'scope data by service' do
    service_two = FactoryBot.create(:service, :account => @provider_account)
    plan = FactoryBot.create( :application_plan, :issuer => service_two)
    cinstance = FactoryBot.create(:cinstance, :plan => plan)

    service_three = FactoryBot.create(:service, :account => @provider_account)

    data = Pdf::Data.new(@provider_account, @service, :period => :day)
    assert data.latest_users(5).empty?

    data = Pdf::Data.new(@provider_account, service_two, :period => :day)
    assert data.latest_users(5).present?

    # regression test for https://3scale.airbrake.io/projects/14982/groups/1653940878125329519/notices/1664087453881268542
    service_three.stubs(cinstances: apps = stub_everything('apps', latest: service_two.cinstances.latest))
    apps.stubs(reorder: apps)

    data = Pdf::Data.new(@provider_account, service_three, :period => :day)
    assert data.latest_users(5).empty?
  end

  test 'return distinct accounts' do
    buyer      = FactoryBot.create(:buyer_account, :provider_account => @provider_account)
    plan       = FactoryBot.create(:application_plan, :issuer => @service)
    cinstance  = FactoryBot.create(:cinstance, :plan => @plan, :user_account => buyer)
    cinstance2 = FactoryBot.create(:cinstance, :plan => plan, :user_account => buyer)
    cinstance3 = FactoryBot.create(:cinstance, :user_account => buyer)

    data = Pdf::Data.new(@provider_account, @service, :period => :day)
    assert_equal 1, data.latest_users(5).size
  end

  test 'return ordered accounts' do
    buyer1     = FactoryBot.create(:buyer_account, :org_name => 'first', :provider_account => @provider_account, :created_at => 1.day.ago)
    buyer2     = FactoryBot.create(:buyer_account, :org_name => 'second', :provider_account => @provider_account, :created_at => 5.days.ago)
    buyer3     = FactoryBot.create(:buyer_account, :org_name => 'third', :provider_account => @provider_account, :created_at => 10.days.ago)

    plan1 = FactoryBot.create( :application_plan, :issuer => @service, :created_at => 10.days.ago)
    plan2 = FactoryBot.create( :application_plan, :issuer => @service, :created_at => 5.days.ago)
    plan3 = FactoryBot.create( :application_plan, :issuer => @service, :created_at => 1.day.ago)

    cinstance1 = FactoryBot.create(:cinstance, :plan => plan1, :user_account => buyer1)
    cinstance2 = FactoryBot.create(:cinstance, :plan => plan2, :user_account => buyer2)
    cinstance3 = FactoryBot.create(:cinstance, :plan => plan3, :user_account => buyer3)

    data = Pdf::Data.new(@provider_account, @service, :period => :day)

    assert_equal ['<td>first</td>', '<td>second</td>', '<td>third</td>' ],
                 data.latest_users(3).map(&:first)
  end

  test 'sanitize escape sequences' do
    buyer1     = FactoryBot.create(:buyer_account, :org_name => 'fi\rst buye\r', :provider_account => @provider_account, :created_at => 1.day.ago)
    buyer2     = FactoryBot.create(:buyer_account, :org_name => 'seco\nd buyer\r\n', :provider_account => @provider_account, :created_at => 5.days.ago)
    buyer3     = FactoryBot.create(:buyer_account, :org_name => '\nthi\rd buyer', :provider_account => @provider_account, :created_at => 10.days.ago)

    plan1 = FactoryBot.create( :application_plan, :issuer => @service, :created_at => 10.days.ago)
    plan2 = FactoryBot.create( :application_plan, :issuer => @service, :created_at => 5.days.ago)
    plan3 = FactoryBot.create( :application_plan, :issuer => @service, :created_at => 1.day.ago)

    FactoryBot.create(:cinstance, :plan => plan1, :user_account => buyer1)
    FactoryBot.create(:cinstance, :plan => plan2, :user_account => buyer2)
    FactoryBot.create(:cinstance, :plan => plan3, :user_account => buyer3)

    data = Pdf::Data.new(@provider_account, @service, :period => :day)

    assert_equal ['<td>fi\\\rst buye\\\r</td>', '<td>seco\\\nd buyer\\\r\\\n</td>', '<td>\\\nthi\\\rd buyer</td>' ],
                 data.latest_users(3).map(&:first)
  end
end
