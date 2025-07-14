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

Then "they should see the credit card is stored" do
  within_billing_status_card do
    assert_text "Credit Card details are on file. Card expires in: #{buyer_credit_card_expiration_date.strftime('%B %Y')}"
  end
end

Then "they should see the credit card is not stored" do
  within_billing_status_card do
    assert_text 'Credit Card details are not stored'
  end
end

And "monthly billing can be disabled" do
  accept_confirm do
    within_billing_status_card do
      click_button 'Disable billing'
    end
  end

  within_billing_status_card do
    assert_text 'Monthly billing is disabled.'
  end
end

And "monthly charging can be disabled" do
  accept_confirm do
    within_billing_status_card do
      click_button 'Disable charging'
    end
  end

  within_billing_status_card do
    assert_text 'Monthly billing is enabled.'
    assert_text 'Monthly charging is disabled.'
  end
end

Then "setting {string} should be {word}" do |switch, state|
  within_plan_settings_card do
    find('td', text: switch).sibling('td', text: state.camelize)
  end
end

Then "setting {string} can be enabled" do |switch|
  within_plan_settings_card do
    accept_confirm do
      find('td', text: switch).sibling('td:last-of-type')
                              .click_button('enable')
    end
  end

  within_plan_settings_card do
    find('td', text: switch).assert_sibling('td', text: 'Hidden')
  end
end

And "{provider} {is} able to access billing" do |provider, enabled|
  assert_equal enabled, Ability.new(provider.admins.first).can?(:manage, :finance)
end

def within_billing_status_card(&block)
  within billing_status_card_selector do
    yield block
  end
end

def billing_status_card_selector
  '.pf-c-card #finance-status'
end

def within_plan_settings_card(&block)
  within '#provider-change-plan .pf-c-card' do
    yield block
  end
end
