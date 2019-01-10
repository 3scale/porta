require 'test_helper'

class PdfReportWorkerTest < ActiveSupport::TestCase

  def test_enqueue
    service = FactoryBot.create(:simple_service)
    operation = SystemOperation.for(:weekly_reports)

    assert_difference PdfReportWorker.jobs.method(:count) do
      PdfReportWorker.enqueue(service, :week, operation)
    end
  end

  def test_perform_with_system_operation
    service = FactoryBot.create(:simple_service)
    FactoryBot.create(:simple_user, role: :admin, account: service.account)
    service.account.mail_dispatch_rules.create!(system_operation: SystemOperation.for(:weekly_reports), dispatch: true)
    service.account.mail_dispatch_rules.create!(system_operation: SystemOperation.for(:daily_reports), dispatch: true)
    worker = PdfReportWorker.new

    assert_difference ActionMailer::Base.deliveries.method(:count) do
      worker.perform(service.id, service.account.id, 'week', 'weekly_reports')
    end

    Pdf::Report.any_instance.expects(:mail_report).once
    worker.perform(service.id, service.account.id, 'day', 'daily_reports')
  end

  def test_perform_not_enabled
    service = FactoryBot.create(:simple_service)
    FactoryBot.create(:simple_user, role: :admin, account: service.account)
    worker = PdfReportWorker.new

    Pdf::Report.any_instance.expects(:send_notification!).never
    Pdf::Report.any_instance.expects(:mail_report).never

    assert_no_difference ActionMailer::Base.deliveries.method(:count) do
      worker.perform(service.id, service.account.id, 'week', 'weekly_reports')
      worker.perform(service.id, service.account.id, 'day', 'daily_reports')
    end
  end

  def test_perform_with_notification
    service = FactoryBot.create(:simple_service)
    admin = FactoryBot.create(:simple_user, role: :admin, account: service.account)
    admin.notification_preferences.enabled_notifications = %w(weekly_report daily_report)
    admin.notification_preferences.save!
    worker = PdfReportWorker.new

    assert_difference ActionMailer::Base.deliveries.method(:count) do
      worker.perform(service.id, service.account.id, 'week', 'weekly_reports')
    end

    Pdf::Report.any_instance.expects(:send_notification!).once
    worker.perform(service.id, service.account.id, 'day', 'daily_reports')
  end
end
