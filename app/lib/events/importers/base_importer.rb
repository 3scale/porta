module Events
  module Importers
    class BaseImporter
      attr_reader :object

      class_attribute :services_cache

      def initialize(object)
        @object = object
      end

      def is_master_event?
        Account.master.first_service! == service
      end

      def user_tracking
        user_account = cinstance.user_account
        user = user_account.try(:first_admin)

        unless user_account
          Rails.logger.error "Can't notify #{self.class} import because contract #{cinstance.id} does not have user account"
          return
        end

        unless user
          Rails.logger.error "Can't notify #{self.class} import because contract #{cinstance.id} does not have user"
        end

        ThreeScale::Analytics.user_tracking(user)
      end

      def cinstance
        return @cinstance if instance_variable_defined?(:@cinstance)
        @cinstance = object.cinstance || service.cinstances.find_by_application_id(object.application_id)
        Rails.logger.warn("Missing cinstance for application_id #{object.application_id}") unless @cinstance
        @cinstance
      end

      def service
        return object.service if object.service
        service_id = object.service_id.to_i
        self.class.services_cache ||= {}
        self.class.services_cache[service_id] ||= ::Service.find(service_id)
      end

      def self.clear_cache
        self.services_cache = {}
      end
    end
  end
end

