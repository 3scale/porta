
When /^I fill in the user invitation needed data$/ do
  @user_attrs = Factory.attributes_for(:user)
  fill_in 'Send invitation to', :with => @user_attrs[:email]
end

Then /^I should see the invite user link$/ do
  response.should have_tag('a', /Invite new user to this account/)
end

Then /^I should see a new buyer user was invited$/ do
  step %{I should see "Partner user invitation was successfully sent."}
  Invitation.find_by_email(@user_attrs[:email]).should_not be_nil
end

Then /^I should see the invitations item activated in the partners menu$/ do
  step %{I should see the "Invitations" item activated in the partners menu}
end
