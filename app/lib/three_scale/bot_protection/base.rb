# frozen_string_literal: true

module ThreeScale
  module BotProtection
    module Base
      def bot_protection_level
        site_account.settings.spam_protection_level
      end

      def bot_protection_enabled?
        Recaptcha.captcha_configured? && bot_protection_level != :none
      end
    end
  end
end
