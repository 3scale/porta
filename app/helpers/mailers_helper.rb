# frozen_string_literal: true

module MailersHelper
  def master_mailer_name
    ThreeScale.config.onpremises ? Account.master.org_name : '3scale'
  end

  def prepare_email(subject:, to:, **options)
    opt_headers = options[:headers]
    headers(opt_headers) if opt_headers
    mail(
      template_name: options[:template] || action_name,
      subject: subject,
      to: to
    )
  end
end
