class ApiDocs::Mailer < ActionMailer::Base

  def new_path_notification(service)
    @service = service
    @account = service.account
    @base_path = service.base_path
    @reply_to = service.account.support_email

    mail(:subject =>  "New ActiveDocs Path added: #{service.base_path}",
         :to => support_email,
         :from => service.account.support_email)
  end

  private

  def support_email
    name, at = Rails.configuration.three_scale.support_email.split('@')
    [name + "+api-docs-proxy", at].join('@')
  end

end
