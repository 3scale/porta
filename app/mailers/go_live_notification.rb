class GoLiveNotification < ActionMailer::Base

  default to: ThreeScale.config.golive_email,
          from: ThreeScale.config.notification_email

  def notice(account)
    @account = account
    mail(subject: "Integrated through heroku: #{@account.domain}")
  end
end
