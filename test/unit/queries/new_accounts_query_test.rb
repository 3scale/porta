require 'test_helper'

class NewAccountsQueryTest < ActiveSupport::TestCase

  def setup
    @simple_provider    = FactoryGirl.create :simple_provider
    @new_accounts_query = NewAccountsQuery.new @simple_provider
  end

  def test_within_timeframe
    current_range = Date.parse('2014-10-10')..Date.parse('2014-11-20')
    out_of_range  = Date.parse('2013-1-1')..Date.parse('2013-2-1')

    data = @new_accounts_query.within_timeframe(range: current_range)

    assert_equal current_range.to_a.size, data.size
    assert_equal 0, delete_zero_values(data).size

    FactoryGirl.create :simple_buyer, provider_account: @simple_provider,
      created_at: DateTime.parse('2014-10-15')

    data = @new_accounts_query.within_timeframe(range: current_range)

    assert_equal current_range.to_a.size, data.size
    assert_equal 1, delete_zero_values(data).size

    data = @new_accounts_query.within_timeframe(range: out_of_range)

    assert_equal out_of_range.to_a.size, data.size
    assert_equal 0, delete_zero_values(data).size
  end

  def test_within_timeframe_with_granularity
    range = [
      DateTime.parse('2013-12-31T23:00'),
      DateTime.parse('2014-1-1T00:00'),
      DateTime.parse('2014-1-1T01:00')
    ]

    FactoryGirl.create :simple_buyer, provider_account: @simple_provider,
      created_at: DateTime.parse('2014-1-1T00:29')

    data = @new_accounts_query.within_timeframe(range: range, granularity: :year)

    assert_equal data.keys, ['2013', '2014']

    assert_equal 0, data.fetch('2013')
    assert_equal 1, data.fetch('2014')

    data = @new_accounts_query.within_timeframe(range: range, granularity: :month)

    assert_equal data.keys, ['2013-12', '2014-01']

    assert_equal 0, data.fetch('2013-12')
    assert_equal 1, data.fetch('2014-01')

    data = @new_accounts_query.within_timeframe(range: range, granularity: :day)

    assert_equal data.keys, ['2013-12-31', '2014-01-01']

    assert_equal 0, data.fetch('2013-12-31')
    assert_equal 1, data.fetch('2014-01-01')

    data = @new_accounts_query.within_timeframe(range: range, granularity: :hour)

    assert_equal data.keys, ['2013-12-31T23', '2014-01-01T00', '2014-01-01T01']

    assert_equal 0, data.fetch('2013-12-31T23')
    assert_equal 1, data.fetch('2014-01-01T00')
    assert_equal 0, data.fetch('2014-01-01T01')
  end

  class WithinTimeframeTest < self

    def setup
      super

      @range = [DateTime.parse('2010-12-31'), DateTime.parse('2011-1-1')]

      # saving date is
      # 2010.12.31 in Pacific time
      # 2011.01.01 in UTC
      FactoryGirl.create :simple_buyer, provider_account: @simple_provider,
        created_at: DateTime.parse('2010-12-31T23:00:00-08:00')
    end

    def test_within_timeframe_in_pacific_time
      Time.use_zone('Pacific Time (US & Canada)') do

        # query based on the default timezone - Pacific time
        data = @new_accounts_query.within_timeframe(range: @range, granularity: :day)

        assert_equal 1, data.fetch('2010-12-31')
        assert_equal 0, data.fetch('2011-01-01')
      end
    end

    def test_within_timeframe_in_utc
      Time.use_zone 'UTC' do

        # query based on the default timezone - UTC
        data = @new_accounts_query.within_timeframe(range: @range, granularity: :day)

        assert_equal 0, data.fetch('2010-12-31')
        assert_equal 1, data.fetch('2011-01-01')
      end
    end

    def test_within_timeframe_in_invalid_timezone
      # query should works even without the time zone information tables
      # no time zone information tables situation is the same -
      # as asking for the timezone which does not exist
      Time.zone.tzinfo.stubs(name: 'TimezoneWhichDoesNotExist')

      data = @new_accounts_query.within_timeframe(range: @range, granularity: :day)

      assert_equal 0, data.fetch('2010-12-31')
      assert_equal 1, data.fetch('2011-01-01')
    end
  end

  private

  def delete_zero_values(hash)
    hash.delete_if { |key, value| value.zero? }
  end
end
