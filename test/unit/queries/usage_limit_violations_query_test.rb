require 'test_helper'

class UsageLimitViolationsQueryTest < ActiveSupport::TestCase
  def setup
    # TODO: use simple factory and fix Account#buyer_alerts
    @provider = FactoryGirl.create(:simple_provider)
    @query = UsageLimitViolationsQuery.new(@provider)
  end

  def test_usage_limit_violations
    assert @query.usage_limit_violations.empty?

    create_alert

    assert @query.usage_limit_violations.empty?

    create_violation

    refute @query.usage_limit_violations.empty?
  end

  def test_in_range
    Time.use_zone('Pacific Time (US & Canada)') do

      Timecop.freeze(2010, 1, 1) do
        assert_equal Time.zone.now, create_violation.timestamp
      end

      Timecop.freeze(2010, 1, 2) do
        range = @query.in_range(1.day.ago..Time.zone.now)
        assert range.present?
      end

    end
  end

  def test_usage_limit_violation
    violation = UsageLimitViolationsQuery::UsageLimitViolation.new(account_id: 1,
                                                                   account_name: 'foo',
                                                                   alerts_count: 42)

    assert_equal 42, violation.alerts_count

    assert account = violation.account
    assert_equal 1, account.id
    assert_equal 'foo', account.name
  end

  def create_alert
    FactoryGirl.create(:limit_alert,
                       account: @provider,
                       cinstance: FactoryGirl.create(:simple_cinstance))
  end

  def create_violation
    FactoryGirl.create(:limit_violation,
                       account: @provider,
                       cinstance: FactoryGirl.create(:simple_cinstance))
  end
end
