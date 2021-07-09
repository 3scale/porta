# frozen_string_literal: true

require 'test_helper'

class ApplicationsHelperTest < ActionView::TestCase
  test "raw_buyers" do
    skip 'TODO'
  end

  test "filtered_buyers" do
    skip 'TODO'
  end

  test "raw_products" do
    skip 'TODO'
  end

  test "filtered_products" do
    skip 'TODO'
  end

  test "paginated_buyers" do
    skip 'TODO'
  end

  test "paginated_products" do
    skip 'TODO'
  end

  test "create_application_link_href(account)" do
    skip 'TODO'
  end

  test "last_traffic(cinstance)" do
    skip 'TODO'
  end

  test "time_tag_with_title(date_or_time, *args)" do
    skip 'TODO'
  end

  test "new_application_form_base_data(provider, cinstance)" do
    skip 'TODO'
  end

  test "most_recently_created_buyers" do
    skip 'TODO'
  end

  test "most_recently_updated_products" do
    skip 'TODO'
  end

  test "application_defined_fields_data(provider)" do
    skip 'TODO'
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
