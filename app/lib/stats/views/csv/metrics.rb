module Stats
  module Views
    module Csv

      Metric = Struct.new(:system_name, :name, :values)

      class Metrics

        def initialize(data)
          @data = data
        end

        def collection
          unless @data[:metrics].nil?
            @data[:metrics].collect do |m|
              Metric.new(m[:system_name], m[:name], m[:data][:values])
            end
          else
            [Metric.new(@data[:metric][:system_name], @data[:metric][:name], @data[:values])]
          end
        end
      end

    end
  end
end