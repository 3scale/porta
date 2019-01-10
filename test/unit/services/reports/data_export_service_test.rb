require 'test_helper'

class Reports::DataExportServiceTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:simple_provider, org_name: 'ontheroad')
  end

  def test_initialize
    assert Reports::DataExportService.new(@provider, 'users', 'week')
  end

  def test_files
    service = Reports::DataExportService.new(@provider, 'users', 'week')

    service.expects(:file_date).returns('2016-07-25')

    service.files.each do |name, string_file|
      assert_equal name, '3scale-report-ontheroad-2016-07-25.zip'

      ::Zip::InputStream.open(StringIO.new(string_file)) do |zip|
        assert entry = zip.get_next_entry
        assert_match '3scale-report-ontheroad-2016-07-25.csv', entry.name
      end
    end
  end

  def test_exporter
    service = Reports::DataExportService.new(@provider, 'users', 'week')

    assert_equal service.send(:exporter), Csv::BuyersExporter

    service = Reports::DataExportService.new(@provider, 'messages', 'week')

    assert_equal service.send(:exporter), Csv::MessagesExporter

    service = Reports::DataExportService.new(@provider, 'applications', 'week')

    assert_equal service.send(:exporter), Csv::ApplicationsExporter

    assert_raise RuntimeError do
      Reports::DataExportService.new(@provider, '999', 'week').send(:exporter)
    end
  end
end
