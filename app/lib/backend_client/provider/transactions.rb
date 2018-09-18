module BackendClient
  class Provider
    module Transactions

      Transaction = Struct.new(:cinstance, :usage, :timestamp)

      def latest_transactions
        transactions = account.services.flat_map { |service| ThreeScale::Core::Transaction.load_all(service.backend_id).to_a }
        process_transactions(transactions.sort_by(&:timestamp).reverse)
      end

      private

      def process_transactions(transactions)
        application_ids = transactions.map(&:application_id)
        cinstances      = preload_cinstances(application_ids)
        services        = preload_services(application_ids)
        metrics         = preload_metrics(services)

        transactions.map do |transaction|
          Transaction.new(cinstances[transaction.application_id],
                          process_usage(transaction.usage, metrics),
                          parse_timestamp(transaction.timestamp))
        end
      end

      def preload_cinstances(application_ids)
        account.provided_cinstances.where(application_id: application_ids).index_by(&:application_id)
      end

      def preload_services(application_ids)
        account.services.joins(:application_plans => [:cinstances]).includes(:metrics).where(:cinstances => {:application_id => application_ids})
      end

      def preload_metrics(services)
        services.map(&:metrics).flatten.index_by(&:id)
      end

      def process_usage(usage, metrics)
        usage.map_keys do |metric_id|
          metrics[metric_id.to_s.to_i] # usage keys (the metric ids) are actually provided as Symbol by ThreeScale::Core
        end
      end

    end
  end
end
