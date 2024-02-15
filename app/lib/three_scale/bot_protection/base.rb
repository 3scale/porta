# frozen_string_literal: true

module ThreeScale
  module BotProtection
    module Base
      private

      def bot_protection_level
        site_account.settings.spam_protection_level
      end

      def bot_protection_enabled?
        Recaptcha.captcha_configured? && bot_protection_level != :none
      end

      unless defined? :site_account
        def site_account
          raise NotImplementedError, "#{self.class} must implement #site_account"
        end
      end
    end
  end
end
