# frozen_string_literal: true

namespace :licenses do  # rubocop:disable Metrics/BlockLength
  report_path = Rails.root.join('doc/licenses/licenses.xml').freeze

  desc 'Generates a report with the dependencies and their licenses'
  task :report do
    warn 'Generating report...'
    license_finder_report(report_path)

    warn 'License report generated.'
    exit 0
  end

  desc 'Check license compliance of dependencies'
  task :compliance do
    warn 'Checking action items...'
    LicenseFinder::CLI::Main.new.action_items # Aborts if there are pending action items

    warn 'Checking license report is up to date...'
    Tempfile.create do |temp_file|
      temp_report_path = temp_file.path
      license_finder_report(temp_report_path)

      unless identical?(report_path, temp_report_path)
        warn 'License report outdated. Please run "rails licenses:report"'
        exit 1
      end
    end

    warn 'License report up to date.'
    exit 0
  end

  private

  def license_finder_report(path)
    cli = LicenseFinder::CLI::Main.new
    cli.options = { "format" => "xml", "save" => path }
    cli.report
  end
end
