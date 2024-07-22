# frozen_string_literal: true

require 'test_helper'

class ApplicationsHelperTest < ActionView::TestCase
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

    travel_to(today) do
      html = Nokogiri::HTML4.parse last_traffic(application)
      time = html.css('time')

      assert_equal '1 day ago', time.attribute('title').value
      assert_equal 'January  1, 2021', time.text
    end
  end

  test "time_tag_with_title" do
    html = Nokogiri::HTML4.parse time_tag_with_title(Date.new(2021, 1, 1))
    time = html.css('time')

    assert_equal 'January 01, 2021', time.attribute('title').value
    assert_equal 'January 01, 2021', time.text
  end

  test "remaining_trial_days default" do
    application = FactoryBot.create(:cinstance, trial_period_expires_at: nil)
    expected_text = '– trial expires in less than a minute'

    html = Nokogiri::HTML4.parse remaining_trial_days(application)
    assert_equal expected_text, html.text
  end

  test "remaining_trial_days expired" do
    today = Time.zone.now
    application = FactoryBot.build(:cinstance, trial_period_expires_at: today - 1.day)
    expected_text = '– trial expires in 1 day'

    travel_to(today) do
      html = Nokogiri::HTML4.parse remaining_trial_days(application)
      assert_equal expected_text, html.text
    end
  end

  test "remaining_trial_days should return the right expiration date text" do
    today = Time.zone.now
    application = FactoryBot.build(:cinstance, trial_period_expires_at: today + 1.day)
    expected_text = '– trial expires in 1 day'

    travel_to(today) do
      html = Nokogiri::HTML4.parse remaining_trial_days(application)
      assert_equal expected_text, html.text
    end
  end
end
