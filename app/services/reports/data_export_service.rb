class Reports::DataExportService
  attr_reader :provider, :type, :period

  EXPORTERS = {
    'users' => Csv::BuyersExporter,
    'messages' => Csv::MessagesExporter,
    'applications' => Csv::ApplicationsExporter,
    'invoices' => Csv::InvoicesExporter
  }.freeze

  def initialize(provider, type, period)
    @provider = provider
    @type     = type
    @period   = period
  end

  def files
    { zip_name => zip_file }
  end

  private

  def zip_file
    zip(csv_name => csv_file).read
  end

  def csv_file
    exporter.new(provider, exporter_params).to_csv
  end

  def file_date
    DateTime.now.in_time_zone.strftime('%Y-%m-%d')
  end

  def file_name
    @file_name ||= "3scale-report-#{provider.org_name.to_param}-#{file_date}"
  end

  def zip_name
    "#{file_name}.zip"
  end

  def csv_name
    "#{file_name}.csv"
  end

  def exporter
    EXPORTERS[type] || raise("Exporter for #{type} not found")
  end

  def exporter_params
    {
      period: period,
      data:   type
    }
  end

  def zip(files)
    buffer = ::Zip::OutputStream.write_buffer do |zip|
      files.each do |file, content|
        zip.put_next_entry file
        zip.print content
      end
    end

    buffer.close_write
    buffer.rewind
    buffer
  end
end
