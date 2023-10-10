# frozen_string_literal: true

Given "a message(s) sent from {provider_or_buyer} to {provider_or_buyer} with subject {string} and body {string}" do |sender, receiver, subject, body|
  message = sender.messages.create!(:to => receiver, :subject => subject, :body => body)
  message.deliver!
end

And "{int} message(s) sent from {provider_or_buyer} to {provider_or_buyer} with subject {string} and body {string}" do |count, sender, receiver, subject, body|
  count.to_i.times do
    message = sender.messages.create!(to: receiver, subject: subject, body: body)
    message.deliver!
  end
end

Given "{provider_or_buyer} has no messages" do |account|
  account.messages.each(&:destroy)
  account.received_messages.destroy_all
end

When /^I press a button to restore the message from "([^"]*)" with subject "([^"]*)"$/ do |from, subject|
  find_delete_button_in_row('Restore', from, subject).click
end

Then "a message should be sent from {provider_or_buyer} to {provider_or_buyer} with subject {string} and body {string}" do |sender, receiver, subject, body|
  message = receiver.received_messages.to_a.find do |message|
    message.sender  == sender  &&
    message.subject == subject &&
    message.body    == body
  end

  assert_not_nil message, %(No message from #{sender.org_name} to #{receiver.org_name} with subject "#{subject}" and body "#{body}" was sent)
end

Then('a message should be sent from buyer to provider with plan change details from free to paid') do
  sender = @buyer
  receiver = @provider
  subject = "API System: Application plan change"
  body = "plan from #{@free_application_plan.name} to #{@paid_application_plan.name}"

  message = receiver.received_messages.to_a.find do |message|
    message.sender  == sender  &&
    message.subject == subject &&
    message.body    =~ /#{body}/
  end

  assert_not_nil message, %(No message from #{sender.org_name} to #{receiver.org_name} with subject "#{subject}" and body "#{body}" was sent)
end

Then('a message should be sent from buyer to provider requesting to change plan to paid') do
  messages = @provider.received_messages.where.has { |t| t.message.sender_id == @buyer.id }
  assert msg = messages.to_a.select{|m| m.subject == 'API System: Plan change request' }.last

  assert_match %(#{@buyer.org_name} are requesting to have their plan changed to #{@paid_application_plan.name} for application #{@application.name}. You can do this from the application page), msg.body
end

Then "there should be no message from {provider} to {buyer} with subject {string}" do |sender, receiver, subject|
  messages = receiver.received_messages.to_a.select do |message|
    message.sender  == sender &&
    message.subject == subject
  end

  assert messages.empty?
end

Then "the message from {provider} to {buyer} with subject {string} should be hidden" do |sender, receiver, subject|
  message = receiver.hidden_messages.to_a.find do |message|
    message.sender  == sender &&
    message.subject == subject
  end

  assert_not_nil message
end

Then "the {string} field should be fixed to {string}" do |field, value|
  assert has_field?(field, readonly: true, with: value)
end

Then /^I should see message to "([^"]*)" with subject "([^"]*)"$/ do |to, subject|
  assert has_table_row_with_cells?(to, subject)
end

Then /^(?:I|they) should see (read|unread) message from "([^"]*)" with subject "([^"]*)"$/ do |state, from, subject|
  assert page.has_xpath?("//tr[@class='#{state}']/descendant::*[text()[contains(.,#{subject.inspect})]]/ancestor::tr/descendant::*[text()[contains(.,#{from.inspect})]]")
end

Then /^I should see a message from "([^"]*)" with subject "([^"]*)"$/ do |from, subject|
  assert has_table_row_with_cells?(from, subject)
end

Then /^I should not see a message from "([^"]*)" with subject "([^"]*)"$/ do |from, subject|
  assert has_no_table_row_with_cells?(from, subject)
end

When "the email will fail when sent" do
  Message.any_instance.stubs(:save).returns(false).once
end
