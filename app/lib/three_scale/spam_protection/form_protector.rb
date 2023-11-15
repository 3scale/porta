# frozen_string_literal: true

module ThreeScale::SpamProtection
  class FormProtector
    include Recaptcha::ClientHelper

    def initialize(form, controller)
      @form = form
      @controller = controller
      @store = @controller.store
    end

    def http_method
      ActiveSupport::StringInquirer.new(@form.template.controller.request.method.to_s.downcase)
    end

    def level
      if @form.template
        @form.template.controller.level
      else
        :none
      end
    end

    def captcha_needed?
      captcha_required? || @store.marked_as_possible_spam?
    end

    def enabled?
      level != :none
    end

    # Reads the store to decide whether to show the captcha or not.
    #
    # The value is saved in the store from Protector#spam_check on a previous PU or POST request.
    def to_str
      return ''.html_safe unless enabled?

      buff = []

      if captcha_needed?
        Rails.logger.info "[SpamProtection] CAPTCHA is needed. Inserting reCaptcha."

        buff << recaptcha_tags(:callback => 'onCaptchaSuccess', :error_callback => 'onCaptchaFail', :expired_callback => 'onCaptchaFail')
        buff << @form.semantic_errors(:recaptcha)
      else
        Rails.logger.info "[SpamProtection] CAPTCHA not needed. Inserting regular checks."

        buff = @controller.spam_protection_conf.checks.map do |check|
          check.input(@form)
        end
      end

      buff.compact.join.html_safe
    end

    alias to_s to_str

    private

    def captcha_required?
      (Recaptcha.captcha_configured? && level == :captcha)
    end
  end
end
