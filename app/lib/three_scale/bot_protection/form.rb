# frozen_string_literal: true

module ThreeScale
  module BotProtection
    module Form
      include Base
      include Recaptcha::Adapters::ViewMethods

      delegate :site_account, to: :template

      private

      def bot_protection_inputs
        return ''.html_safe unless bot_protection_enabled?

        recaptcha_v3(action: template.controller.controller_path)
      end
    end
  end
end
