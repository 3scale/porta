# frozen_string_literal: true

namespace :licenses do  # rubocop:disable Metrics/BlockLength
  report_path = Rails.root.join('doc/licenses/licenses.xml').freeze

  desc 'Generates a report with the dependencies and their licenses'
  task :report do
    warn 'Generating report...'
    license_finder_report(report_path)

    warn 'License report generated.'
  end

  desc 'Check license compliance of dependencies'
  task :compliance do
    warn 'Checking action items...'
    LicenseFinder::CLI::Main.new.action_items # Aborts if there are pending action items

    # Skip report file checks if it is not under source control.
    next unless File.exist?(report_path)

    warn 'Checking license report is up to date...'
    Tempfile.create do |temp_file|
      temp_report_path = temp_file.path
      license_finder_report(temp_report_path)

      unless identical?(report_path, temp_report_path)
        system("diff", "-u", report_path.to_s, temp_report_path.to_s)
        abort 'License report outdated. Please run "rails licenses:report"'
      end
    end

    warn 'License report up to date.'
  end

  private

  def license_finder_report(path)
    cli = LicenseFinder::CLI::Main.new
    cli.options = { "format" => "xml", "save" => path }
    cli.report
  end
end
