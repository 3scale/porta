module Liquid
  module Forms
    class PasswordChange < Forms::Update

      def html_class_name
        'formtastic user'
      end

      def path
        admin_account_password_path
      end

      def render(content)
        super(content + password_reset_token)
      end

      private

      def password_reset_token
        tag(:input, type: 'hidden', name: 'password_reset_token', value: object.to_s)
      end
    end
  end
end
