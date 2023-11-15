# frozen_string_literal: true

module ThreeScale::SpamProtection

  module Integration

    module Controller
      extend ActiveSupport::Concern

      class_methods do

        def enabled_checks
          _enabled_checks
        end

        def has_spam_protection(*checks)
          self._enabled_checks = checks.presence || AVAILABLE_CHECKS
        end
      end

      included do
        delegate :spam?, :spam_probability, to: :spam_protection
        class_attribute :_enabled_checks, instance_reader: false, instance_writer: false
        before_action :instantiate_checks
      end

      def instantiate_checks
        spam_protection_conf.enable_checks! self.class.enabled_checks
      end

      def spam_protection
        @spam_protection ||= ThreeScale::SpamProtection::Protector.new(self)
      end

      def spam_protection_conf
        @spam_protection_conf ||= ThreeScale::SpamProtection::Configuration.new(self)
      end

      def spam_protection_form(form)
        ThreeScale::SpamProtection::FormProtector.new(form, self)
      end

      def store
        @store ||= SessionStore.new(request.session)
      end

      def level
        site_account.settings.spam_protection_level
      end

      private

      def spam_check_save(object)
        (block_given? ? yield : object.save) if spam_check(object)
      end

      def verify_captcha(object)
        verify_recaptcha(model: object, attribute: :recaptcha)
      end

      # Called when a form is received. Usually through a PUT or POST request.
      # Checks the received data to try to detect bots.
      #
      # FormProtector#to_str will read the result of this call in the next GET request to load the form.
      def spam_check(object)
        case level
        when :none
          true
        when :auto
          if spam?
            @store.mark_possible_spam
            Rails.logger.debug "[SpamProtection][Integration] Captcha filled and object is spam - verifying captcha"
            verify_captcha(object)
          else
            Rails.logger.debug "[SpamProtection][Integration] Not Spam"
            true
          end
        when :captcha
          Rails.logger.debug "[SpamProtection][Integration] Captcha mode - verifying captcha"
          verify_captcha(object)
        else
          System::ErrorReporting.report_error "Unknown spam_protection level: #{level}"
        end
      end
    end
  end
end
