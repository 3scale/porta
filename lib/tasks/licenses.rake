# frozen_string_literal: true

namespace :licenses do  # rubocop:disable Metrics/BlockLength
  require 'license_finder'

  report_path = Rails.root.join('doc/licenses/licenses.xml')

  desc 'Generates a report with the dependencies and their licenses'
  task :report do
    warn 'Generating report...'
    license_finder_report(report_path)

    warn 'License report generated.'
    exit 0
  end

  desc 'Check license compliance of dependencies'
  task :compliance do
    warn 'Checking license action items...'
    unless cli.action_items
      warn '*** License compliance test failed  ***'
      exit 1
    end

    warn 'Checking license report is up to date...'
    temp_report_path = Tempfile.new(report_path.to_s).path
    license_finder_report(temp_report_path)

    unless identical?(report_path, temp_report_path)
      warn '*** License report outdated. Please run "rails licenses:report" ***'
      exit 1
    end

    warn 'License report up to date.'
    exit 0
  end

  private

  def cli
    @cli ||= LicenseFinder::CLI::Main.new
  end

  def license_finder_report(path)
    cli.options = { "format" => "xml", "save" => path }
    cli.report
  end
end
