require_dependency 'csv/exporter'

module Stats
  module Views
    module Csv
      class TopApplications < ::Csv::Exporter

        def initialize(data)
          @data = data
        end

        def generate
          super do |csv|
            csv << header

            applications.each do |app|
              csv << [app[:name], app[:id], app[:plan][:name], app[:plan][:id], app[:account][:name], app[:account][:id], app[:value]]
            end
          end
        end

        def filename
          "top-applications-#{Time.zone.now.to_i}.csv"
        end

        private

        def header
          ["Application Name", "Application ID", "Plan Name", "Plan ID", "Account Name", "Account ID", "Total"]
        end

        def applications
          @data[:applications]
        end
      end

    end
  end
end
