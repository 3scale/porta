require 'test_helper'

class Pdf::ReportTest < ActiveSupport::TestCase

  setup do
    @account = FactoryBot.create(:simple_provider)
    @service = FactoryBot.create(:simple_service, account: @account)

    @report = Pdf::Report.new(@account, @service, period: :day).generate
  end

  test 'send_notification!' do
    user = FactoryBot.create(:simple_user, role: :admin, account: @account)
    user.create_notification_preferences!(enabled_notifications: %w[daily_report])

    assert_difference ActionMailer::Base.deliveries.method(:count) do
      assert @report.send_notification!
    end
  end

  test 'notification_name' do
    @report.period = :day
    assert_equal :daily_report, @report.notification_name

    @report.period = :week
    assert_equal :weekly_report, @report.notification_name
  end

  test 'generate without metrics' do
    account = FactoryBot.build_stubbed(:simple_provider)
    service = FactoryBot.build_stubbed(:simple_service, account: account)

    report = Pdf::Report.new(account, service, period: :day)

    assert report.generate
  end

  test 'sanitize html entitites' do
    account = FactoryBot.build_stubbed(:simple_provider)
    service = FactoryBot.build_stubbed(:simple_service, account: account, name: 'Name Contains & Symbol')

    report = Pdf::Report.new(account, service, period: :day)

    assert report.generate
  end
end
