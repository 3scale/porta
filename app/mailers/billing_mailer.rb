class BillingMailer < ActionMailer::Base
  default from: ThreeScale.config.notification_email

  def billing_finished(results)
    @results = results
    verb = @results.successful? ? 'succeeded' : 'failed'

    mail(to: ThreeScale.config.sysadmin_email,
         subject: "Billing and charging #{verb} (#{@results.period})")
  end
end
