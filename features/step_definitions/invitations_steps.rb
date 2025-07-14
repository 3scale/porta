# frozen_string_literal: true

# TODO: the second step wording reads better, replace the occurences of the first one
Given "an invitation from {account} sent to {string}" do |account, email|
  FactoryBot.create(:invitation, account: account, email: email)
end

Given "an invitation sent to {string} to join {account}" do |address, account|
  FactoryBot.create(:invitation, account: account, email: address)
end

#  Given the following invitations from the provider exists:
#    | Email             | State    |
#    | alice@example.org | pending  |
#    | bob@example.org   | accepted |
#
Given "the following invitation(s) from {provider_or_buyer}:" do |account, table|
  parameterize_headers(table)
  table.hashes.each do |row|
    email = row.delete('email')
    accepted = case state = row.delete('state')
               when 'accepted' then true
               when 'pending' then false
               else
                 raise ArgumentError, "Invitations are either 'accepted' or 'pending', not #{state}"
               end

    FactoryBot.create(:invitation, account: account,
                                   email: email,
                                   accepted: accepted)
  end
end

Given "an/the invitation sent to {string} to join {account} was accepted" do |address, account|
  FactoryBot.create(:invitation, account: account, email: address)
  invitation = account.invitations.find_by_email!(address)
  invitation.accept!
end

When(/^I follow the link to signup in the invitation sent to "([^\"]*)"$/) do |address|
  open_email(address)
  click_first_link_in_email
end

When "the invitee follows the link to sign up to {provider} in the invitation sent to {string}" do |provider, address|
  open_email(address)
  set_current_domain(provider.external_admin_domain)
  click_first_link_in_email
end

# OPTIMIZE: this reads awful
When "I press {string} for an invitation from {account} for {string}" do |label, account, email|
  invitation = account.invitations.find_by_email!(email)
  within "##{dom_id(invitation)}" do
    click_link(label)
  end
end

When(/^I resend the invitation to "([^\"]*)"$/) do |email|
  # these ivars are preparing for the expectation steps that follow
  invitation = Invitation.find_by_email email
  @last_emails_count = ActionMailer::Base.deliveries.size
  click_link "resend-invitation-#{invitation.id}"
end

When(/^I send "([^"]*)" an invitation to account "([^"]*)"$/) do |address, org_name|
  click_link(href: admin_buyers_accounts_path)
  click_link org_name
  find('a', text: /invitations?/i, match: :one).click
  click_link 'Invite user'
  @invitee_email = address
  fill_in('Send invitation', with: address)
  click_button 'Send'
end

When(/^I navigate to the page of the invitations of the partner "([^\"]*)"$/) do |_org_name|
  click_link(href: admin_buyers_accounts_path)
  click_link 'lol cats'
  find('a', text: /invitations?/i, match: :one).click
end

When(/^I send an invitation to "([^\"]*)"$/) do |address|
  click_link 'Invite user'
  @invitee_email = address
  fill_in('Send invitation', with: address)
  click_button 'Send'
end

# this compound When/Then steps are a result of the exception raising of the When step,
# see the lambda use
When(/^I request the url of the invitations of the partner "([^\"]*)"$/) do |org_name|
  partner = Account.find_by_org_name org_name
  visit admin_buyers_account_invitations_path(partner)
end

When(/^I send a provider invitation to "([^\"]*)"$/) do |address|
  select_context 'Account Settings'
  visit provider_admin_account_users_path

  click_link 'Invite a New User'
  fill_in 'Send invitation to', with: address
  click_button 'Send'
end

# TODO: agree on a wording for these 2 steps and leave only one
Then "{string} should receive an invitation to {account}" do |address, account|
  invitation_message_should_be_valid find_latest_email(to: address), account
end

Then "an invitation with the admin domain of {account} should be sent to {string}" do |provider, address|
  invitation_message_should_be_valid find_latest_email(to: address), provider, provider.external_admin_domain
end

Then(/^(?:the |)invitation (?:to|from) account "([^\"]*)" should be sent to "([^\"]*)"$/) do |org_name, email|
  invitation_message_should_be_valid find_latest_email(to: email), Account.find_by(org_name: org_name)
end

Then(/^no invitation should be sent to "([^"]*)"$/) do |email|
  assert_nil find_latest_email(to: email)
end

Then(/^I should see the invitations page of the partner "([^\"]*)"$/) do |org_name|
  assert has_content?("Sent invitations for #{org_name}")
end

Then /^the table should contain an? (accepted|pending) invitation from "(.*)"$/ do |state, email|
  accepted = state == 'accepted'

  assert(all('tr').any? do |tr|
    tr.has_css?('td', wait: 0, text: email) &&
    tr.has_css?('td', wait: 0, text: accepted ? /^yes/ : 'no')
  end)
end

Then(/^I should not see invitation for "([^"]*)"$/) do |email|
  assert has_no_css?('td', text: email)
end

Then(/^I should be able to resend the invitation to "([^\"]*)"$/) do |email|
  assert have_css?("button#resend-invitation-#{Invitation.find_by_email(email).id}")
end

Then(/^I should not be able to resend the invitation to "([^\"]*)"$/) do |email|
  assert have_no_css?("button#resend-invitation-#{Invitation.find_by_email(email).id}")
end

Then(/^I should see the invitation for "([^\"]*)" on top of the list$/) do |address|
  assert has_xpath?("//table[@id='invitations']/tbody/tr[1]/td[1]", text: /#{address}/)
end

Then(/^I should see an error saying an user with that email already exists$/) do
  assert has_content?('has been taken by another user')
end

Then "invitation from {account} should be resent to {string}" do |account, address|
  assert_equal @last_emails_count + 1, ActionMailer::Base.deliveries.length
  message = ActionMailer::Base.deliveries.last
  assert message.to.include?(address)

  invitation_message_should_be_valid message, account
end
