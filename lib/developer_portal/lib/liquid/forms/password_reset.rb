module Liquid
  module Forms
    class PasswordReset < Forms::Create

      def html_class_name
        'formtastic'
      end

      def path
        admin_account_password_path
      end
    end
  end
end
