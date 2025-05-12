# frozen_string_literal: true

module ThreeScale
  module BotProtection
    module Controller
      include Base
      include Recaptcha::Adapters::ControllerMethods

      private

      def bot_check(options = { flash: true })
        return true unless bot_protection_enabled?

        return verify_captcha(options) if bot_protection_level == :captcha

        System::ErrorReporting.report_error "Unknown spam_protection level: #{bot_protection_level}"
      end

      def verify_captcha(options)
        success = verify_recaptcha(action: controller_path, minimum_score: Rails.configuration.three_scale.recaptcha_min_bot_score)

        flash.now[:danger] = flash[:recaptcha_error] if options[:flash] && flash.key?(:recaptcha_error)
        flash.delete(:recaptcha_error)

        success
      end
    end
  end
end
