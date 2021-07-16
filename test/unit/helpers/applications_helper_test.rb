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

  def service_plans_management_visible?
    true
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
    buyer = FactoryBot.create(:simple_buyer)

    assert buyer.bought_cinstances.size.zero?
    assert_equal new_admin_buyers_account_application_path(buyer), create_application_link_href(buyer)
  end

  test "new application path when multiple applications enabled" do
    buyer = FactoryBot.create(:simple_buyer)
    FactoryBot.create(:simple_cinstance, user_account: buyer)
    expects(:can?).with(:admin, :multiple_applications).returns(true).once
    expects(:can?).with(:see, :multiple_applications).returns(true).once

    assert_not buyer.bought_cinstances.size.zero?
    assert_equal new_admin_buyers_account_application_path(buyer), create_application_link_href(buyer)
  end

  test "new application path when upgrade needed" do
    buyer = FactoryBot.create(:simple_buyer)
    FactoryBot.create(:simple_cinstance, user_account: buyer)

    expects(:can?).with(:admin, :multiple_applications).returns(true).once
    expects(:can?).with(:see, :multiple_applications).returns(false).once

    assert_not buyer.bought_cinstances.size.zero?
    assert_equal admin_upgrade_notice_path(:multiple_applications), create_application_link_href(buyer)
  end

  test "new application path when single application" do
    buyer = FactoryBot.create(:simple_buyer)
    FactoryBot.create(:simple_cinstance, user_account: buyer)

    expects(:can?).with(:admin, :multiple_applications).returns(false)

    assert_not buyer.bought_cinstances.size.zero?
    assert_nil create_application_link_href(buyer)
  end

  test "last_traffic first day" do
    application = FactoryBot.create(:cinstance)
    application.expects(:first_daily_traffic_at?).returns(false).once

    assert_nil last_traffic(application)
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

  test "new_application_form_base_data" do
    form_data = new_application_form_base_data(provider)

    expected_keys = %i[create-application-plan-path create-service-plan-path service-subscriptions-path service-plans-allowed defined-fields]
    unexpected_keys = %i[most-recently-updated-products products-count buyer errors product most-recently-created-buyers buyers-count]

    assert_same_elements expected_keys, form_data.keys
    unexpected_keys.each { |key| assert_does_not_contain form_data.keys, key }
  end

  test "new_application_form_base_data with application" do
    application = FactoryBot.create(:cinstance)

    form_data = new_application_form_base_data(provider, application)

    expected_keys = %i[create-application-plan-path create-service-plan-path service-subscriptions-path service-plans-allowed defined-fields errors]
    unexpected_keys = %i[most-recently-updated-products products-count buyer product most-recently-created-buyers buyers-count]

    assert_same_elements expected_keys, form_data.keys
    unexpected_keys.each { |key| assert_does_not_contain form_data.keys, key }
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

  test "remaining_trial_days default" do
    application = FactoryBot.create(:cinstance, trial_period_expires_at: nil)
    expected_text = '– trial expires in less than a minute'

    html = Nokogiri::HTML.parse remaining_trial_days(application)
    assert_equal expected_text, html.text
  end

  test "remaining_trial_days expired" do
    today = Time.zone.now
    application = FactoryBot.build(:cinstance, trial_period_expires_at: today - 1.day)
    expected_text = '– trial expires in 1 day'

    Timecop.freeze(today) do
      html = Nokogiri::HTML.parse remaining_trial_days(application)
      assert_equal expected_text, html.text
    end
  end

  test "remaining_trial_days should return the right expiration date text" do
    today = Time.zone.now
    application = FactoryBot.build(:cinstance, trial_period_expires_at: today + 1.day)
    expected_text = '– trial expires in 1 day'

    Timecop.freeze(today) do
      html = Nokogiri::HTML.parse remaining_trial_days(application)
      assert_equal expected_text, html.text
    end
  end
end
