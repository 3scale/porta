# frozen_string_literal: true

# TODO: the second step wording reads better, replace the occurences of the first one
Given "an invitation from {account} sent to {string}" do |account, email|
  FactoryBot.create(:invitation, account: account, email: email)
end

Given "an invitation sent to {string} to join {account}" do |address, account|
  FactoryBot.create(:invitation, account: account, email: address)
end

Given "the following invitations from {account} exist:" do |account, table|
  table.hashes.each do |row|
    invitation = FactoryBot.create(:invitation, account: account, email: row['Email'])
    invitation.accept! if row['State'] == 'accepted'
  end
end

Given "an/the invitation sent to {string} to join {account} was accepted" do |address, account|
  FactoryBot.create(:invitation, account: account, email: address)
  invitation = account.invitations.find_by!(email: address)
  invitation.accept!
end

When "I follow the link to signup in the invitation sent to {string}" do |address|
  open_email(address)
  step 'I click the first link in the email'
end

When "I follow the link to signup provider {string} in the invitation sent to {string}" do |provider, address|
  open_email(address)
  step %(current domain is the admin domain of provider "#{provider}")
  step 'I click the first link in the email'
end

# OPTIMIZE: this reads awful
When "I press {string} for an invitation from {account} for {string}" do |label, account, email|
  invitation = account.invitations.find_by!(email: email)
  step %(I follow "#{label}" within "##{dom_id(invitation)}")
end

When "I resend the invitation to {string}" do |email|
  # these ivars are preparing for the expectation steps that follow
  invitation = Invitation.find_by!(email: email)
  @last_emails_count = ActionMailer::Base.deliveries.size
  click_link "resend-invitation-#{invitation.id}"
end

When "I send an invitation" do
  step 'I visit the page to invite users'
  @invitee_email = 'mary@foo.3scale.localhost'
  step %(I fill in "Send invitation to" with "#{@invitee_email}")
  click_button 'Send'
end

When "I send {string} an invitation to account {string}" do |address, org_name|
  step %(I navigate to the page of the invitations of the partner "#{org_name}")
  step %(I send an invitation to "#{address}")
end

When "I request the url to invite users to {string}" do |provider|
  visit "http://#{provider}/account/invitations/new"
end

When "I navigate to the page of the invitations of the partner {string}" do |_org_name|
  step %(I navigate to the page of the partner "lol cats")
  click_on('invitations', match: :one)
end

When "I send an invitation to {string}" do |address|
  step %(I follow "Invite user")
  @invitee_email = address
  step %(I fill in "Send invitation to" with "#{address}")
  step %(I press "Send")
end

# this compound When/Then steps are a result of the exception raising of the When step,
# see the lambda use
When "I request the url of the invitations of the partner {string}" do |org_name|
  partner = Account.find_by!(org_name: org_name)
  visit admin_buyers_account_invitations_path(partner)
end

When "I send a provider invitation to {string}" do |address|
  step %(I navigate to the Account Settings)
  click_link 'Users'
  click_link 'Listing'
  click_link 'Invite a New User'
  fill_in 'Send invitation to', with: address
  click_button 'Send'
end

# TODO: agree on a wording for these 2 steps and leave only one
Then "{string} should receive an invitation to {account}" do |address, account|
  invitation_message_should_be_valid find_latest_email(to: address), account
end

Then "an invitation with the admin domain of {account} should be sent to {string}" do |provider, address|
  invitation_message_should_be_valid find_latest_email(to: address), provider, provider.self_domain
end

Then "(the )invitation to/from account {string} should be sent to {string}" do |org_name, email|
  step %("#{email}" should receive an invitation to account "#{org_name}")
end

Then "no invitation should be sent to {string}" do |email|
  assert_nil find_latest_email(to: email)
end

Then "I should see the link to the partner invitations page" do
  assert has_css?('a', text: 'Invitations')
end

Then "I should see the invitations page of the partner {string}" do |org_name|
  assert has_content?("Sent invitations for #{org_name}")
end

Then "I should see {state} invitation for {string}" do |state, email|
  accepted = state == 'accepted'

  assert(all('tr').any? do |tr|
    tr.has_css?('td', text: email) &&
    tr.has_css?('td', text: accepted ? /^yes/ : 'no')
  end)
end

Then "I should not see invitation for {string}" do |email|
  assert has_no_css?('td', text: email)
end

Then "I should see buttons to resend the invitations" do
  Invitation.all.each do |invitation|
    assert page.has_css?('form', action: %r{/admin\/account\/invitations\/#{invitation.id}\/resend/})
  end
end

Then "I should see the button to resend the invitation to {string}" do |email|
  unaccepted_invitation = Invitation.find_by!(email: email)
  response.should have_tag("a#resend-invitation-#{unaccepted_invitation.id}")
end

Then "I {should} be able to resend the invitation to {string}" do |can_resend, email|
  assert_equal can_resend, have_css?("button#resend-invitation-#{Invitation.find_by!(email: email).id}")
end

Then "I should see the invitation for {string} on top of the list" do |address|
  assert has_xpath?("//table[@id='invitations']/tbody/tr[1]/td[1]", text: /#{address}/)
end

Then "I should see the invitation sign up page" do
  assert has_xpath?('//input[@value="Sign up"]')
end

Then "I should see an error saying an user with that email already exists" do
  assert has_content?('has been taken by another user')
end

Then "invitation from {account} should be resent to {string}" do |account, address|
  assert_equal @last_emails_count + 1, ActionMailer::Base.deliveries.length
  message = ActionMailer::Base.deliveries.last
  assert message.to.include?(address)

  invitation_message_should_be_valid message, account
end
