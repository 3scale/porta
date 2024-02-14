# frozen_string_literal: true

module ThreeScale
  module BotProtection
    module Form
      include Base
      include Recaptcha::Adapters::ViewMethods

      def bot_protection_inputs
        return ''.html_safe unless bot_protection_enabled?

        recaptcha_v3(action: recaptcha_action)
      end

      def recaptcha_action
        controller.controller_path
      end
    end
  end
end
