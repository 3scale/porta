module Backend
  module ModelExtensions
    module UsageLimit
      def self.included(base)
        base.class_eval do
          # TODO: use after_commit_queue and leave these as normal after_save/destroy

          # cache associations
          before_destroy :preload_used_associations

          # TODO: reverse the order of these callbacks, as the default has changed in Rails 7.1, and then remove the
          # config.active_record.run_after_transaction_callbacks_in_order_defined setting
          after_commit :update_backend_usage_limit, :unless => :destroyed?
          after_commit :delete_backend_usage_limit
        end
      end

      def update_backend_usage_limit
        if plan_and_service?
          ThreeScale::Core::UsageLimit.save(:service_id => service.backend_id,
                                            :plan_id    => plan.backend_id,
                                            :metric_id  => metric_id,
                                            period      => value)
        end

        true
      end

      def delete_backend_usage_limit
        if plan_and_service?
          original_period = saved_change_to_period? ? saved_change_to_period.compact.first : period
          ThreeScale::Core::UsageLimit.delete(service.backend_id, plan.backend_id, metric_id, original_period)
        end

        true
      end

      private

      def preload_used_associations
        service.try!(:account)
        plan
      end

      def plan_and_service?
        plan && service
      end
    end
  end
end
