# frozen_string_literal: true

module RecaptchaHelper
  # :reek:UtilityFunction
  def skip_recaptcha(skip)
    Recaptcha::Verify.stubs(:skip?).returns(skip)
  end
end

World(RecaptchaHelper)
