# frozen_string_literal: true

require 'test_helper'

class ApplicationsHelperTest < ActionView::TestCase
  include ActiveJob::TestHelper

  def setup
    @provider = FactoryBot.create(:simple_provider)
  end

  def master_account
    @master_account ||= Account.master || FactoryBot.create(:master_account)
  end

  attr_reader :provider, :pagination_params

  test "raw_buyers" do
    FactoryBot.create_list(:simple_buyer, 10, provider_account: provider)
    provider.buyer_accounts << master_account
    provider.save!

    assert_contains provider.buyer_accounts, master_account
    assert_does_not_contain raw_buyers, master_account
    assert_equal 10, raw_buyers.size
  end

  test "filtered_buyers" do
    b1 = FactoryBot.create(:simple_buyer, name: 'Buyer Pepe', provider_account: provider)
    b2 = FactoryBot.create(:simple_buyer, name: 'Buyer Pepa', provider_account: provider)

    Account.expects(:search_ids).with('all').returns([b1.id, b2.id])
    Account.expects(:search_ids).with('one').returns([b1.id])

    assert_equal 2, filtered_buyers({}).size
    assert_equal 2, filtered_buyers({ query: 'all' }).size
    assert_equal 1, filtered_buyers({ query: 'one' }).size
  end

  test "raw_products" do
    FactoryBot.create_list(:simple_service, 10, account: provider)

    assert_equal 10, raw_products.size
  end

  test "filtered_products" do
    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        FactoryBot.create(:simple_service, name: 'Pepe API', account: provider)
        FactoryBot.create(:simple_service, name: 'Pepa API', account: provider)
      end

      assert_equal 2, filtered_products({}).size
      assert_equal 2, filtered_products({ query: 'api' }).size
      assert_equal 1, filtered_products({ query: 'pepe' }).size
      assert_equal 0, filtered_products({ query: 'asdf' }).size
    end
  end

  test "paginated_buyers" do
    FactoryBot.create_list(:simple_buyer, 10, provider_account: provider)

    @pagination_params = { page: 1, per_page: 5 }
    assert_equal 5, paginated_buyers.size
  end

  test "paginated_products" do
    FactoryBot.create_list(:simple_service, 10, account: provider)

    @pagination_params = { page: 1, per_page: 5 }
    assert_equal 5, paginated_products.size
  end

  test "new application path when no applications" do
    assert account.bought_cinstances.size.zero?

    assert_equal new_admin_buyers_account_application_path(account), create_application_link_href
  end

  test "new application path when multiple applications enabled" do
    assert_not account.bought_cinstances.size.zero?
    assert can?(:admin, :multiple_applications)
    assert can?(:see, :multiple_applications)

    assert_equal new_admin_buyers_account_application_path(account), create_application_link_href

    assert_not can?(:see, :multiple_applications)

    assert_equal admin_upgrade_notice_path(:multiple_applications), create_application_link_href
  end

  test "new application path when single application" do
    assert_not account.bought_cinstances.size.zero?
    assert_not can?(:admin, :multiple_applications)

    assert_equal nil, create_application_link_href
  end

  test "last_traffic first day" do
    application = FactoryBot.create(:cinstance)
    application.expects(:first_daily_traffic_at?).returns(false).once

    assert_equal nil, last_traffic(application)
  end

  test "last_traffic after first day" do
    yesterday = Date.new(2021, 1, 1)
    today = Date.new(2021, 1, 2)

    application = FactoryBot.create(:cinstance)
    application.expects(:first_daily_traffic_at?).returns(true).once
    application.expects(:first_daily_traffic_at).returns(yesterday).once

    Timecop.freeze(today) do
      html = Nokogiri::HTML.parse last_traffic(application)
      time = html.css('time')

      assert_equal '1 day ago', time.attribute('title').value
      assert_equal 'January  1, 2021', time.text
    end
  end

  test "time_tag_with_title" do
    html = Nokogiri::HTML.parse time_tag_with_title(Date.new(2021, 1, 1))
    time = html.css('time')

    assert_equal 'January 01, 2021', time.attribute('title').value
    assert_equal 'January 01, 2021', time.text
  end

  test "remaining_trial_days" do
    application = FactoryBot.create(:cinstance, trial_period_expires_at: nil)
    assert_equal "&ndash; trial expires in".html_safe, remaining_trial_days(application)
  end

  test "new_application_form_base_data(provider, cinstance)" do
    application = FactoryBot.create(:cinstance)

    form_data = new_application_form_base_data(provider, application)

    assert form_data.key? 'create-application-plan-path'
    assert form_data.key? 'create-service-plan-path'
    assert form_data.key? 'service-subscriptions-path'
    assert form_data.key? 'service-plans-allowed'
    assert form_data.key? 'defined-fields'
  end

  test "most_recently_created_buyers is limited to 20" do
    FactoryBot.create_list(:simple_buyer, 21, provider_account: provider)

    assert_equal 20, most_recently_created_buyers.size
  end

  test "most_recently_updated_products is limited to 20" do
    FactoryBot.create_list(:simple_service, 21, account: provider)
    assert_equal 20, most_recently_updated_products.size
  end

  test "application_defined_fields_data" do
    field = FactoryBot.create(:fields_definition, account: provider, target: 'Cinstance')
    data = application_defined_fields_data(provider)

    assert_equal 1, data.size
    assert_equal "cinstance[#{field.name}]", data.first[:name]
  end

  test "remaining_trial_days should return the right expiration date text" do
    time = Time.utc(2015, 1,20, 10, 10, 10)
    cinstance = FactoryBot.build(:cinstance, trial_period_expires_at: time)
    expected_date = '&ndash; trial expires in <time datetime="2015-01-20T10:10:10Z" title="20 Jan 2015 10:10:10 UTC">20 days</time>'

    Timecop.freeze(time - 20.days) do
      assert_equal expected_date, remaining_trial_days(cinstance)
    end
  end
end
