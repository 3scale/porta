module ThreeScale::SpamProtection
  class Protector
    attr_reader :config, :checks
    delegate :check, :to => :config

    def initialize(object, config = object.class.spam_protection)
      @object = object
      @config = config

      # create hash with checks as keys
      @checks = config.active_checks
    end

    def spam_probability
      enabled = @config.active_checks

      probability = enabled.reduce(0) { |sum, check| sum + check.probability(@object) }
      probability.to_f / enabled.count
    end

    def spam?
      probability = spam_probability
      Rails.logger.info { "[SpamProtection] probability is #{probability} and allowed level is #{spam_level}" }
      probability >= spam_level
    end

    def spam_level
      config[:level]
    end

    class FormProtector
      include Recaptcha::Adapters::ViewMethods

      attr_reader :form, :protector, :session_store

      delegate :template, to: :form
      delegate :logged_in?, to: :template, allow_nil: true
      delegate :checks, to: :protector
      delegate :captcha_configured?, to: Recaptcha
      delegate :marked_as_possible_spam?, to: :session_store

      def initialize(form, protector)
        @form = form
        @protector = protector
        @session_store = SessionStore.new(request_session)
      end

      def http_method
        ActiveSupport::StringInquirer.new(template.controller.request.method.to_s.downcase)
      end

      def level
        if template
          template.site_account.settings.spam_protection_level
        else
          :none
        end
      end

      def captcha_required?
        (captcha_configured? && level == :captcha) && !logged_in?
      end

      def captcha_needed?
        captcha_required? || possible_spam?
      end

      def enabled?
        !logged_in? && level != :none
      end

      def to_str
        return ''.html_safe unless enabled?

        buff = []

        if captcha_needed?
          Rails.logger.info "[SpamProtection] CAPTCHA is needed. Inserting reCaptcha."

          buff << recaptcha_tags(:callback => 'onCaptchaSuccess', :error_callback => 'onCaptchaFail', :expired_callback => 'onCaptchaFail')
          buff << form.semantic_errors(:recaptcha)
        else
          Rails.logger.info "[SpamProtection] CAPTCHA not needed. Inserting regular checks."

          buff = checks.map do |check|
            check.input(form)
          end
        end

        buff.compact.join.html_safe
      end

      alias to_s to_str

      private

      def request_session
        return {} if template&.controller.blank?

        template.controller.request.session
      end

      def possible_spam?
        http_method.get? ? marked_as_possible_spam? : mark_possible_spam
      end

      def mark_possible_spam
        return false unless protector.spam?

        session_store.mark_possible_spam
      end
    end

    def form(form)
      FormProtector.new(form, self)
    end
  end
end
