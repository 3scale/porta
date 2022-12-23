# frozen_string_literal: true

Given "an admin is reviewing the buyer's account" do
  visit admin_buyers_account_path(@buyer)
end

Then "they should not see any billing status" do
  assert_not has_css?(billing_status_card_selector)
end

Then "they should see the buyer is being billed monthly" do
  within_billing_status_card do
    assert_text 'Monthly billing is enabled.'
    assert_no_text 'Monthly charging is enabled.'
  end
end

Then "they should see the buyer is being charged monthly" do
  within_billing_status_card do
    assert_text 'Monthly billing is enabled.'
    assert_text 'Monthly charging is enabled.'
  end
end

Then "they should see the credit card {is} stored" do |stored|
  within_billing_status_card do
    if stored
      assert_text "Credit Card details are on file. Card expires in: #{buyer_credit_card_expiration_date.strftime('%B %Y')}"
    else
      assert_text 'Credit Card details are not stored'
    end
  end
end

And "monthly billing can be disabled" do
  within_billing_status_card do
    click_button 'Disable billing'
  end

  within_billing_status_card do
    assert_text 'Monthly billing is disabled.'
  end
end

And "monthly charging can be disabled" do
  within_billing_status_card do
    click_button 'Disable charging'
  end

  within_billing_status_card do
    assert_text 'Monthly billing is enabled.'
    assert_text 'Monthly charging is disabled.'
  end
end

Given "a master admin is reviewing the provider's account" do
  Capybara.app_host = Capybara.default_host = "http://#{Account.master.external_domain}"
  Capybara.always_include_port = true

  try_provider_login(Account.master.admins.first!.username, 'supersecret')

  visit admin_buyers_account_path(@provider)
end

Then "{string} should be {word}" do |switch, state|
  within_plan_settings_card do
    find('td', text: switch).sibling('td', text: state.camelize)
  end
end

Then "{string} can be enabled" do |switch|
  within_plan_settings_card do
    find('td', text: switch).sibling('td', text: 'Denied')
                            .click_button('enable')
  end

  within_plan_settings_card do
    find('td', text: switch).assert_sibling('td', text: 'Hidden')
  end
end

And "the provider should be able to access billing" do
  visit '/p/logout'
  set_current_domain @provider.external_admin_domain
  visit 'p/login'
  try_provider_login(@provider.admins.first.username, 'supersecret')
  click_on 'Billing'
  assert_text 'Earnings by Month'
  assert_equal admin_finance_root_path, current_path
end

def within_billing_status_card(&block)
  within billing_status_card_selector do
    yield block
  end
end

def billing_status_card_selector
  '.dashboard_card #finance-status'
end

def within_plan_settings_card(&block)
  within plan_settings_card_selector do
    yield block
  end
end

def plan_settings_card_selector
  '.dashboard_card#provider-change-plan'
end
