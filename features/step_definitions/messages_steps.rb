# frozen_string_literal: true

Given "the following messages were sent to {provider}" do |provider, table|
  if provider.buyer_accounts.empty?
    step %(a buyer "messenger" signed up to application plan "#{provider.application_plans.first.name}")
  end

  table.hashes.each do |hash|
    msg = provider.buyer_accounts.reload.first.messages.create!(to: provider, subject: hash['Message'], body: hash['Message'])

    msg.update!(created_at: Chronic.parse(hash['Created at'])) if hash['Created at']

    msg.deliver!
  end
end

Given "I the following messages were sent to provider:" do |table|
  assert @provider, "@provider missing"
  step %(the following messages were sent to provider "#{@provider.org_name}":), table
end

And "{amount} message(s) sent from {provider_or_buyer} to {provider_or_buyer} with subject {string} and body {string}" do |amount, sender, receiver, subject, body|
  amount.times do
    message = sender.messages.create!(to: receiver, subject: subject, body: body)
    message.deliver!
  end
end

Given "{account} has no messages" do |account|
  account.messages.each(&:destroy)
  account.received_messages.destroy_all
end

When "I press a button to {word} the message from {string} with subject {string}" do |action, from, subject|
  # TODO: verify action doesn't have to be upper-case
  find_delete_button_in_row(action, from, subject).click
end

Then "a message should be sent from {provider_or_buyer} to {provider_or_buyer} with subject {string} and body match with {string}" do |sender, receiver, subject, body|
  message = receiver.received_messages.to_a.find do |msg|
    msg.sender == sender  &&
      msg.subject == subject &&
      msg.body  =~ /#{body}/
  end

  assert_not_nil message, %(No message from #{sender.org_name} to #{receiver.org_name} with subject "#{subject}" and body "#{body}" was sent)
end

Then "a message should be sent from {provider_or_buyer} to {provider_or_buyer} with subject {string} and body {string}" do |sender, receiver, subject, body|
  message = receiver.received_messages.to_a.find do |msg|
    msg.sender == sender  &&
      msg.subject == subject &&
      msg.body == body
  end

  assert_not_nil message, %(No message from #{sender.org_name} to #{receiver.org_name} with subject "#{subject}" and body "#{body}" was sent)
end

Then "a message should be sent from buyer to provider with plan change details from free to paid" do
  step %(a message should be sent from buyer "#{@buyer.org_name}" to provider "#{@provider.domain}" with subject "API System: Application plan change" and body match with "plan from #{@free_application_plan.name} to #{@paid_application_plan.name}")
end

Then "a message should be sent from buyer to provider requesting to change plan to paid" do
  messages = @provider.received_messages.where.has { |t| t.message.sender_id == @buyer.id }
  assert msg = messages.to_a.select{|m| m.subject == 'API System: Plan change request' }.last

  assert_match %(#{@buyer.org_name} are requesting to have their plan changed to #{@paid_application_plan.name} for application #{@application.name}. You can do this from the application page), msg.body
end

Then "a message should be sent to {provider_or_buyer} with subject {string}" do |receiver, subject|
  message = receiver.received_messages.last
  assert_match subject, message.subject
end

Then "there should be no message from {provider} to {buyer} with subject {string}" do |sender, receiver, subject|
  messages = receiver.received_messages.to_a.select do |message|
    message.sender == sender &&
      message.subject == subject
  end

  assert messages.empty?
end

Then "{account} should have {int} message(s)" do |account, count|
  assert_equal count.to_i, account.messages.count
end

Then "the message from {provider} to {buyer} with subject {string} should be hidden" do |sender, receiver, subject|
  message = receiver.hidden_messages.to_a.find do |msg|
    msg.sender == sender &&
      msg.subject == subject
  end

  assert_not_nil message
end

Then "the 'To' field should be fixed to {string}" do |receiver|
  assert has_no_field?('To')
  assert_equal receiver, find_field("to").value
end

Then "I should see message to {string} with subject {string}" do |to, subject|
  assert has_table_row_with_cells?(to, subject)
end

Then "I should see {word} message from {string} with subject {string}" do |state, from, subject|
  assert page.has_xpath?("//tr[@class='#{state}']/descendant::*[text()[contains(.,#{subject.inspect})]]/ancestor::tr/descendant::*[text()[contains(.,#{from.inspect})]]")
end

Then "I {should} see a message from {string} with subject {string}" do |visible, from, subject|
  assert_equal visible, has_table_row_with_cells?(from, subject)
end
