# frozen_string_literal: true

Given "{provider} has {switch} allowed" do |provider, switch|
  settings = provider.settings
  settings.send("allow_#{switch}!") unless settings.send(switch).allowed?
end

Given "{provider} has {switch} denied" do |provider, switch|
  settings = provider.settings
  settings.send("deny_#{switch}!") unless settings.send(switch).denied?
end

Given "{provider} has {switch} visible" do |provider, switch|
  settings = provider.settings
  settings.send("allow_#{switch}!") unless settings.send(switch).allowed?
  settings.send("show_#{switch}!")  unless settings.send(switch).visible?
end

Given "{provider} has {switch} hidden" do |provider, switch|
  settings = provider.settings
  settings.send("hide_#{switch}!") unless settings.send(switch).hidden?
end

Then /^I should see the invitation to upgrade my plan$/ do
  assert find('a#change-plan.important-button', text: 'Upgrade to')
end

Then /^I should see upgrade notice for "(.+?)"$/ do |switch|
  step %{I should be on the upgrade notice page for "#{switch}"}
end

Then(/^the provider should have credit card on signup switch (hidden|visible)/) do |status|
  # Right now this step is only used in scenarios using Braintree.
  stub_braintree_authorization if status == 'visible'
  settings = @provider.settings
  assert settings.require_cc_on_signup.public_send("#{status}?"), ":require_cc_on_signup should be #{status}"
end
