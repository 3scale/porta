require 'test_helper'

class DataExportsWorkerTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryBot.create(:provider_account)
    @master   = master_account.delete && master_account
    @worker   = DataExportsWorker.new
  end

  def test_perform_for_master
    new_notification_permissions(false)

    assert_difference  'ActionMailer::Base.deliveries.count' do
      assert @worker.perform(@master.id, @master.first_admin.id, 'users', 'week')
    end
  end

  def test_perform
    new_notification_permissions(false)

    assert_no_difference(EventStore::Event.where(event_type: 'Reports::CsvDataExportEvent').method(:count)) do
      assert @worker.perform(@provider.id, @provider.first_admin.id, 'users', 'week')
      assert ActionMailer::Base.deliveries.last
    end



    new_notification_permissions(true)

    assert_difference(EventStore::Event.where(event_type: 'Reports::CsvDataExportEvent').method(:count)) do
      assert @worker.perform(@provider.id, @provider.first_admin.id, 'users', 'week')
    end
  end

  def test_email
    new_notification_permissions(false)

    email = @worker.perform(@provider.id, @provider.first_admin.id, 'users', 'week')

    assert_equal 1, email.attachments.size
    assert part = email.attachments.first

    date = DateTime.now.strftime("%Y-%m-%d")
    report_attachment= "3scale-report-#{@provider.org_name.to_param}-#{date}.zip"

    assert_equal "application/zip; filename=#{report_attachment}", part.content_type
  end

  private

  def new_notification_permissions(result)
    Account.any_instance.expects(:provider_can_use?)
      .with(:new_notification_system).returns(result)
  end
end
