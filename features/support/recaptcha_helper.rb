module RecaptchaHelper
  module VerifyWithUnstub
    def verify_recaptcha(options = {})
      value = super
      Recaptcha.configuration.unstub(:skip_verify_env)
      value
    end
  end

  def captcha_evaluates_to(result)
    controller = ::ActionController::Base.any_instance

    if result
      controller.stubs(:verify_recaptcha).returns do |options|
        controller.unstub(:verify_recaptcha)

        true
      end
    else
      controller.stubs(:verify_recaptcha).returns do |options|
        controller.unstub(:verify_recaptcha)

        if model = options[:model]
          model.errors.add(options[:attribute] || :base,
                         "Word verification response is incorrect, please try again.")
        end

        false
      end
    end
  end

  def skip_recaptcha(skip)
    ::ActionController::Base.class_eval do
      include VerifyWithUnstub unless ancestors.include?(VerifyWithUnstub)
    end

    if skip
      Recaptcha.configuration.stubs(:skip_verify_env).returns([Rails.env])
    else
      Recaptcha.configuration.stubs(:skip_verify_env).returns([])
    end
  end
end

World(RecaptchaHelper)
