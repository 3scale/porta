require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Stats::BaseTest < ActiveSupport::TestCase
  def setup
    provider_account = FactoryBot.create(:provider_account)
    service = provider_account.first_service!

    @stats_base = Stats::Base.new(service)
    range = mock('range', begin: Time.zone.parse('2016-09-18T00:00:00-07:00'), end: Time.zone.parse('2016-09-19T00:59:59-07:00'))
    @stats_base.stubs(:extract_range_and_granularity).returns([range, {granularity: 'day'}])
  end

  test 'Base#period_detail should return the correct timezone' do
    options = {
        metric_name: 'hits',
        since: '2015-10-14T14:45:22',
        granularity: 'month',
        until: '2016-09-14T14:45:22',
        skip_change: true,
        timezone: 'Pacific Time (US & Canada)'
    }
    period_details = @stats_base.send :period_detail, options

    assert_equal 'America/Los_Angeles', period_details[:timezone]
  end

  test 'Base#period_detail should return UTC when timezone is gibberish' do
    options = {
        timezone: 'gibberish'
    }
    period_details = @stats_base.send :period_detail, options

    assert_equal 'Etc/UTC', period_details[:timezone]
  end

  class Stats::BaseExtractTimezoneTest < ActiveSupport::TestCase
    test 'Base#extract_timezone should return nil if a wrong timezone parameter is sent' do
      provider_account = FactoryBot.create(:provider_account)
      service = provider_account.first_service!

      @stats_base = Stats::Base.new(service)
      options = {
          timezone: 'foobar'
      }

      assert_nil @stats_base.send :extract_timezone, options
    end
  end

end
