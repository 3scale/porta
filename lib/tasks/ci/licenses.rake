# frozen_string_literal: true

namespace :ci do
  namespace :license_finder do

    threescale_license_finder_path = Rails.root.join('lib', 'threescale_license_finder', 'bin', 'threescale_license_finder')

    desc 'Run compliance task and generates the license report if complies'
    task :run do
      if Rake::Task['ci:license_finder:compliance'].invoke
        Rake::Task['ci:license_finder:report'].invoke
      end
    end
    desc 'Check license compliance of dependencies'
    task :compliance do
      STDOUT.puts 'Checking license compliance'
      unless system("BUNDLE_GEMFILE='Gemfile' #{threescale_license_finder_path}")
        STDERR.puts "*** License compliance test failed  ***"
        exit 1
      end
    end
    desc 'Generates a report with the dependencies and their licenses'
    task :report do
      STDOUT.puts 'Generating report...'
      licenses_xml_path = Rails.root.join('doc', 'licenses', 'licenses.xml')
      exec("BUNDLE_GEMFILE='Gemfile' #{threescale_license_finder_path} report --format=xml > #{licenses_xml_path}")
    end
  end
end
