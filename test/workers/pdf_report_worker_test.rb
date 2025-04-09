require 'test_helper'

class PdfReportWorkerTest < ActiveSupport::TestCase

  def test_enqueue
    service = FactoryBot.create(:simple_service)

    assert_difference PdfReportWorker.jobs.method(:count) do
      PdfReportWorker.enqueue(service, :week)
    end
  end

  def test_perform_not_enabled
    service = FactoryBot.create(:simple_service)
    FactoryBot.create(:simple_user, role: :admin, account: service.account)
    worker = PdfReportWorker.new

    Pdf::Report.any_instance.expects(:send_notification!).never
    Pdf::Report.any_instance.expects(:mail_report).never

    assert_no_difference ActionMailer::Base.deliveries.method(:count) do
      worker.perform(service.id, service.account.id, 'week')
      worker.perform(service.id, service.account.id, 'day')
    end
  end

  def test_perform_with_notification
    service = FactoryBot.create(:simple_service)
    admin = FactoryBot.create(:simple_user, role: :admin, account: service.account)
    admin.notification_preferences.enabled_notifications = %w(weekly_report daily_report)
    admin.notification_preferences.save!
    worker = PdfReportWorker.new

    assert_difference ActionMailer::Base.deliveries.method(:count) do
      worker.perform(service.id, service.account.id, 'week')
    end

    Pdf::Report.any_instance.expects(:send_notification!).once
    worker.perform(service.id, service.account.id, 'day')
  end
end
