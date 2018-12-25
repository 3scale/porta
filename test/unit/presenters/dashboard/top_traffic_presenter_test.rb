require 'test_helper'

class TopTrafficPresenterTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
  end

  def test_present
    dashboard = Dashboard::TopTrafficPresenter.new(stats, apps)
    cinstance = create_cinstance

    assert_equal(false, dashboard.present?)
    fake_traffic!(cinstance, 40.days.ago..37.days.ago, value: 1)
    assert_equal(false, dashboard.present?) # is cached

    dashboard = Dashboard::TopTrafficPresenter.new(stats, apps)
    assert_equal(true, dashboard.present?)
  end

  def test_each
    dashboard = Dashboard::TopTrafficPresenter.new(stats, apps)

    first, second, third = Array.new(3) { |i| create_cinstance(name: "app #{i+1}") }

    fake_traffic!(third, 40.days.ago..40.days.ago, value: 10)
    fake_traffic!(second, 40.days.ago..40.days.ago, value: 5)
    fake_traffic!(second, 10.days.ago..10.days.ago, value: 5)
    fake_traffic!(first,  40.days.ago..40.days.ago, value: 3)
    fake_traffic!(first,  10.days.ago..10.days.ago, value: 10)

    items = dashboard.each.to_a
    assert_equal 3, items.size

    first, second, third = items

    assert_kind_of Dashboard::TopTraffic::TopAppPresenter, first
    assert_equal 1, first.position
    assert_equal 'app 1', first.name

    assert_kind_of Dashboard::TopTraffic::TopAppPresenter, second
    assert_equal 2, second.position
    assert_equal 'app 2', second.name

    assert_kind_of Dashboard::TopTraffic::LeftAppPresenter, third
    assert_nil third.position
    assert_equal 'app 3', third.name
  end

  def stats
    Stats::Service.new(@provider.first_service!)
  end

  # @return [Cinstance]
  def create_cinstance(attributes = {})
    plan = FactoryBot.create(:simple_application_plan, issuer: @provider.first_service!)
    FactoryBot.create(:simple_cinstance, attributes.merge(plan: plan))
  end

  def apps
    @provider.provided_cinstances
  end
end
