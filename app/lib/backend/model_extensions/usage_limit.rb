module Backend
  module ModelExtensions
    module UsageLimit
      def self.included(base)
        base.class_eval do
          # TODO: use after_commit_queue and leave these as normal after_save/destroy

          # cache associations
          before_destroy :preload_used_associations

          # WARN: last callback is called first, gotcha!
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
          original_period = previously_changed?(:period) ? previous_changes[:period].compact.first : period
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
