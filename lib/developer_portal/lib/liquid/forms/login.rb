module Liquid
  module Forms
    class Login < Forms::BotProtected

      def html_class_name
        'formtastic session'
      end

      def form_options
        super.merge(id: 'new_session')
      end

      def path
        session_path
      end

      def recaptcha_action
        DeveloperPortal::Engine.routes.recognize_path(login_path).fetch(:controller)
      end
    end
  end
end
