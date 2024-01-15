# frozen_string_literal: true

module RecaptchaHelper
  # :reek:UtilityFunction
  def skip_recaptcha(skip)
    Recaptcha.stubs(:skip_env?).returns(skip)
  end
end

World(RecaptchaHelper)
