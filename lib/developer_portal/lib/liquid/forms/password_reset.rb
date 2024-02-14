# frozen_string_literal: true

module Liquid
  module Forms
    class PasswordReset < Forms::BotProtected

      def html_class_name
        'formtastic'
      end

      def path
        admin_account_password_path
      end

      def recaptcha_action
        DeveloperPortal::Engine.routes.recognize_path(path).fetch(:controller)
      end
    end
  end
end
