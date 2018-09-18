module BackendClient
  class Application
    module Utilization

      def utilization(metrics_list)
        utilization_records = ThreeScale::Core::Utilization.load(service_id, id)
        process_utilization(utilization_records, metrics_list)
      rescue
        System::ErrorReporting.report_error($!)
        Collection.error($!)
      end

      class Collection < Array
        attr_accessor :exception

        def self.error(exception)
          new.tap do |collection|
            collection.exception = exception
          end
        end

        def error?
          !!@exception
        end
      end

      private

      def process_utilization(records, metrics_list)
        metrics_by_name = metrics_list.index_by(&:system_name)

        # Cannot call #map! on a ThreeScale::Core::APIClient::Collection instance
        records = records.map do |record|
          attributes = record.attributes.merge(metric: metrics_by_name[record.metric_name])
          UtilizationRecord.new attributes
        end

        finite, infinite = records.partition(&:finite?)
        finite.sort_by!(&:percentage).reverse!

        Collection.new(infinite + finite)
      end
    end
  end
end
