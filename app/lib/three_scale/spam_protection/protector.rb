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

    def is_spam?
      probability = spam_probability
      Rails.logger.info { "[SpamProtection] probability is #{probability} and allowed level is #{spam_level}" }
      probability >= spam_level
    end
    alias spam? is_spam?

    def spam_level
      config[:level]
    end

    class FormProtector
      include Recaptcha::ClientHelper

      attr_reader :form, :protector

      delegate :template, to: :form
      delegate :logged_in?, to: :template, allow_nil: true
      delegate :is_spam?, :checks, to: :protector
      delegate :captcha_configured?, to: Recaptcha

      def initialize(form, protector)
        @form = form
        @protector = protector
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
        captcha_required? || (!http_method.get? && is_spam?)
      end

      def enabled?
        not logged_in? and level != :none
      end

      def to_str
        return ''.html_safe unless enabled?

        buff = []

        if captcha_needed?
          Rails.logger.info "[SpamProtection] CAPTCHA is needed. Inserting reCaptcha."

          buff << recaptcha_tags
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
    end

    def form(form)
      FormProtector.new(form, self)
    end
  end
end
