# frozen_string_literal: true

module Backend
  module ModelExtensions
    module Service
      def self.included(base)
        base.class_eval do
          after_commit :update_backend_service, :unless => :destroyed?
        end
      end

      alias_attribute :backend_id, :id

      def update_backend_service
        if account&.has_bought_cinstance?
          save_options = {
            :id                         => backend_id,
            :provider_key               => account.api_key,
            :referrer_filters_required  => referrer_filters_required,
            :backend_version            => backend_version,
            :default_service            => (account.default_service_id == id)
          }
          ThreeScale::Core::Service.save!(save_options)
        end

        true
      rescue => e
        System::ErrorReporting.report_error e
        raise e
      end

      def delete_backend_service
        return if account&.missing_api_key?
        delete_alert_limits(alert_limits) if account.try(:api_key?)
        ThreeScale::Core::Service.delete_by_id!(backend_id)
        true
      rescue => e
        System::ErrorReporting.report_error e
        raise e
      end

      private

      def make_default_backend_service
        ThreeScale::Core::Service.make_default(backend_id)
        account.update!({default_service_id: id}, without_protection: true)
      end
    end
  end
end
