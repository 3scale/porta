And(/^the users should receive the application has been deleted notification email$/) do
  @provider.users.each do |user|
    step %("#{user.email}" should receive an email with subject "Alexisonfire has been deleted")
  end
end

And(/^the users should receive the service contract cancelled notification email$/) do
  @provider.users.each do |user|
    subject = "#{user.account.name} has cancelled their subscription"

    step %("#{user.email}" should receive an email with subject "#{subject}")
  end
end

And(/^the users should receive the application created notification email$/) do
  registered_buyer = @provider.buyers.last
  application      = registered_buyer.contracts.last
  service          = application.service
  subject          = "#{application.name} created on #{service.name}"

  @provider.users.each do |user|
    step %("#{user.email}" should receive an email with subject "#{subject}")
  end
end

And(/^the users should receive the account created notification email$/) do
  registered_buyer = @provider.buyers.last
  registered_user  = registered_buyer.users.last
  subject          = "#{registered_user.informal_name} from #{registered_buyer.name} signed up"

  @provider.users.each do |user|
    step %("#{user.email}" should receive an email with subject "#{subject}")
  end
end

And(/^the users should receive the account deleted notification email$/) do
  @provider.users.each do |user|
    subject = 'Account Alexander deleted'

    step %("#{user.email}" should receive an email with subject "#{subject}")
  end
end

And(/^the users should receive the service contract created notification email$/) do
  registered_buyer = @provider.buyers.last
  application      = registered_buyer.contracts.last
  service          = application.service
  subject          = "#{registered_buyer.name} has subscribed to your service #{service.name}"

  @provider.users.each do |user|
    step %("#{user.email}" should receive an email with subject "#{subject}")
  end
end
