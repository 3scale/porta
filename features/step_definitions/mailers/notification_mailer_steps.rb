# frozen_string_literal: true

And(/^the users should receive the application created notification email$/) do
  registered_buyer = @provider.buyers.last
  application      = registered_buyer.contracts.last
  service          = application.service
  subject          = "#{application.name} created on #{service.name}"

  @provider.users.each do |user|
    assert_equal(1, unread_emails_for(user.email).count { |m| m.subject =~ Regexp.new(Regexp.escape(subject)) })
  end
end

And(/^the users should receive the account created notification email$/) do
  registered_buyer = @provider.buyers.last
  registered_user  = registered_buyer.users.last
  subject          = "#{registered_user.decorate.informal_name} from #{registered_buyer.name} signed up"

  @provider.users.each do |user|
    assert_equal(1, unread_emails_for(user.email).count { |m| m.subject =~ Regexp.new(Regexp.escape(subject)) })
  end
end

And(/^the users should receive the account deleted notification email$/) do
  @provider.users.each do |user|
    subject = 'Account Alexander deleted'

    assert_equal(1, unread_emails_for(user.email).count { |m| m.subject =~ Regexp.new(Regexp.escape(subject)) })
  end
end

And(/^the users should receive the service contract created notification email$/) do
  registered_buyer = @provider.buyers.last
  application      = registered_buyer.contracts.last
  service          = application.service
  subject          = "#{registered_buyer.name} has subscribed to your service #{service.name}"

  @provider.users.each do |user|
    assert_equal(1, unread_emails_for(user.email).count { |m| m.subject =~ Regexp.new(Regexp.escape(subject)) })
  end
end
