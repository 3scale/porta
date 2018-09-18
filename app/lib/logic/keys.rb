# frozen_string_literal: true

module Logic
  module Keys
    module ApplicationContract
      def create_key_after_create?
        oauth? || mandatory_app_key? and application_keys.empty?
      end

      def mandatory_app_key?
        self.service.backend_version.to_s == '2' && self.service.mandatory_app_key?
      end

      def can_delete_key?
        !mandatory_app_key? or self.application_keys.size > 1
      end
    end
  end
end
