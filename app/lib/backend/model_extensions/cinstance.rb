module Backend
  module ModelExtensions
    module Cinstance
      def self.included(base)

        base.class_eval do

          before_destroy :preload_used_associations
          before_validation :set_application_id, :on => :create

          after_commit :update_provider_backend_service_if_user_key_changed, :on => :update

          after_commit :update_backend_user_key_to_application_id_mapping, unless: :destroyed?

          after_commit :update_backend_application, unless: :destroyed?

          attr_readonly :application_id
        end
      end

      def update_backend_application
        if plan && service
          state = self.state
          state = :active if live?

          ThreeScale::Core::Application.save( :service_id => service.backend_id,
                                              :id         => application_id,
                                              :state      => state,
                                              :plan_id    => plan.id,
                                              :plan_name  => plan.name,
                                              :redirect_url => redirect_url )
        end

        true
      end

      def delete_backend_application
        if service.present? && service.id.present? && application_id.present?
          ThreeScale::Core::Application.delete(service.backend_id, application_id)
        else
          Rails.logger.warn("Cinstance id: #{id}, application_id: #{application_id} cannot be deleted from backend")
        end
        true
      end

      def update_backend_user_key_to_application_id_mapping
        user_key_was, current_user_key = saved_change_to_user_key

        if saved_change_to_user_key? && service.id.present? && user_key_was.present?
          ThreeScale::Core::Application.delete_id_by_key(service.backend_id, user_key_was)
        end

        ## save no matter what, even if not changed, it's safe. Required for backend rake task that are
        ## unaware of previous changes
        if !service.nil? && user_key.present?
          ThreeScale::Core::Application.save_id_by_key(service.backend_id, user_key, application_id)
        end

        true
      end

      def delete_backend_user_key_to_application_id_mapping
        return true if !service || !service.id || user_key.blank?
        ThreeScale::Core::Application.delete_id_by_key(service.backend_id, user_key)
        true
      end

      private

      def preload_used_associations
        service.account if service
        plan
      end


      def set_application_id
        self.application_id ||= SecureRandom.hex(4)
      end

      def update_provider_backend_service_if_user_key_changed
        if saved_change_to_user_key?
          user_key_was, user_key = saved_change_to_user_key

          if user_account && user_account.provider? && user_key_was.present? && user_account.services.present?
            ThreeScale::Core::Service.change_provider_key!(user_key_was, user_key)
          end
        end

        true
      end
    end
  end
end
