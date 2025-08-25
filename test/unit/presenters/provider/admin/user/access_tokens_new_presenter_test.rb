# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::User::AccessTokensNewPresenterTest < ActiveSupport::TestCase

  Presenter = Provider::Admin::User::AccessTokensNewPresenter

  setup do
    @provider = FactoryBot.create(:simple_provider)
  end

  test "#provider_timezone_offset always returns same offset for timezones without DST" do
    @provider.timezone = "Minsk"
    target = Presenter.new(@provider)
    expected_offset = 10800

    offset_winter = travel_to(Time.utc(2025, 12, 1)) { target.provider_timezone_offset }
    offset_summer = travel_to(Time.utc(2025, 8, 1)) { target.provider_timezone_offset }

    assert_equal offset_winter, offset_summer
    assert_equal expected_offset, offset_summer
  end

  test "#provider_timezone_offset returns different offset in summer and winter, for timezones with DST" do
    @provider.timezone = "Berlin"
    target = Presenter.new(@provider)
    expected_winter_offset = 3600
    expected_summer_offset = 7200

    offset_winter = travel_to(Time.utc(2025, 12, 1)) { target.provider_timezone_offset }
    offset_summer = travel_to(Time.utc(2025, 8, 1)) { target.provider_timezone_offset }

    assert_not_equal offset_winter, offset_summer
    assert_equal expected_winter_offset, offset_winter
    assert_equal expected_summer_offset, offset_summer
  end
end
