require_dependency 'csv/exporter'

module Stats
  module Views
    module Csv

      class Usage < ::Csv::Exporter

        def initialize(data, options = {})
          @data = data
          @options = options
        end

        def generate
          super do |csv|
            csv << header

            Metrics.new(@data).collection.each do |metric|
              date = since
              metric.values.each do |datum|
                csv << [metric.system_name, metric.name, date, datum]
                date += addend
              end
            end
          end
        end

        def filename
          [@options[:target], 'usage', Time.zone.now.to_i].compact.join('-') + '.csv'
        end
        private

        def header
          ["Metric System Name", "Metric Name", "Date", "Value"]
        end

        def addend
          @addened ||= case period
                       when "day"
                1.hour
                       when "week"
                6.hours
                       when "month"
                1.day
                       when "year"
                1.month
              end
        end

        def period
          @period ||= @data[:period][:name]
        end

        def since
          @since ||= @data[:period][:since]
        end

      end

    end
  end
end
