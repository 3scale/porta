module Backend
  module ModelExtensions
    module Service
      def self.included(base)
        base.class_eval do
          after_commit :update_backend_service, :unless => :destroyed?
          after_commit :delete_backend_service, :on => :destroy
        end
      end

      def backend_id
        preffix_key
      end

      def update_backend_service
        if account && account.has_bought_cinstance?
          save_options = {
            :id                         => backend_id,
            :provider_key               => account.api_key,
            :referrer_filters_required  => referrer_filters_required,
            :backend_version            => backend_version,
            :default_user_plan_name     => default_end_user_plan.try!(:name),
            :default_user_plan_id       => default_end_user_plan.try!(:backend_id),
            :default_service            => (account.default_service_id == self.id),
            :user_registration_required => self.end_user_registration_required
          }
          ThreeScale::Core::Service.save!(save_options)
        end

        true
      rescue => e
        System::ErrorReporting.report_error e
        raise e
      end

      def delete_backend_service
        if account && account.has_bought_cinstance? && !account.api_key.blank?
          delete_alert_limits(alert_limits)
          ThreeScale::Core::Service.delete_by_id!(backend_id)
        end

        true
      rescue => e
        System::ErrorReporting.report_error e
        raise e
      end

      private

      def make_default_backend_service
        ThreeScale::Core::Service.make_default(backend_id)
      end
    end
  end
end
