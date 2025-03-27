require 'test_helper'

class DataExportsWorkerTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryBot.create(:provider_account)
    @master   = master_account.delete && master_account
    @worker   = DataExportsWorker.new
  end

  def test_perform
    assert_difference(EventStore::Event.where(event_type: 'Reports::CsvDataExportEvent').method(:count)) do
      assert @worker.perform(@provider.id, @provider.first_admin.id, 'users', 'week')
    end
  end
end
