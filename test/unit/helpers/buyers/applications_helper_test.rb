# frozen_string_literal: true

require 'test_helper'

class Buyers::ApplicationsHelperTest < ActionView::TestCase

  test 'new_application_form_metadata' do
    data = { foo: 'bar' }
    ProviderDecorator.any_instance.stubs(:new_application_form_data).returns(data)
    provider = FactoryBot.create(:provider_account)

    assert_equal data, new_application_form_metadata(provider)
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
