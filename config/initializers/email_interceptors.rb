ActiveSupport.on_load(:action_mailer) do

ActionMailer::Base.register_interceptor ThreeScale::EmailEngagementFooter
ActionMailer::Base.register_interceptor ThreeScale::EmailDoNotSendInterceptor
ActionMailer::Base.register_interceptor ThreeScale::ValidateEmailInterceptor

# set per environment (see config/environments/edge.rb for example)
settings = Rails.configuration.three_scale.email_sanitizer

if settings.enabled
  ActionMailer::Base.register_interceptor(ThreeScale::EmailSanitizer.new(settings.to))
  Rails.logger.info "Email sanitizer enabled (#{settings.to})"
end

end
