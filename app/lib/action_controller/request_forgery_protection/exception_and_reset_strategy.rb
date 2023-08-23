# frozen_string_literal: true

module ActionController
  module RequestForgeryProtection
    class ExceptionAndResetStrategy
      def initialize(controller)
        @controller = controller
      end

      def handle_unverified_request
        @controller.reset_session
        exception.handle_unverified_request
      end

      private

      def exception
        @exception || ActionController::RequestForgeryProtection::ProtectionMethods::Exception.new(@controller)
      end
    end
  end
end
