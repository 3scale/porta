# frozen_string_literal: true

Given "I have enough email configs to fill many pages" do
  25.times { FactoryBot.create(:email_configuration, account: master_account) }
end

Then "the latest email configurations are listed first" do
  with_scope email_configurations_table do
    rows_emails = find_all('tbody tr td:first-child').first(5).map(&:text)
    assert_same_elements rows_emails, master_account.email_configurations.order(id: :desc).first(5).pluck(:email)
  end
end

Then "I should not see all my email configurations" do
  total = master_account.email_configurations.size
  default_per_page = 20
  assert total > default_per_page

  assert_equal default_per_page, email_configurations_table.find_all('tbody tr').length
end

Then "I should be able to go to the next page" do
  find('.pf-c-button[data-action="next"]').click
end

Then "I should be able to filter them by email and user name" do
  FactoryBot.create(:email_configuration, account: master_account, email: "griphook@gringots.co.uk", user_name: "Hookgrip")
  FactoryBot.create(:email_configuration, account: master_account, email: "ragnok@gringots.co.uk", user_name: "Nokrag")

  filter_email_config('griphook')
  with_scope(email_configurations_table) { assert_equal 1, find_all('tbody tr').length }

  filter_email_config('hookgrip')
  with_scope(email_configurations_table) { assert_equal 1, find_all('tbody tr').length }

  filter_email_config('ragnok')
  with_scope(email_configurations_table) { assert_equal 1, find_all('tbody tr').length }

  filter_email_config('nokrag')
  with_scope(email_configurations_table) { assert_equal 1, find_all('tbody tr').length }

  filter_email_config('gringots')
  with_scope(email_configurations_table) { assert_equal 2, find_all('tbody tr').length }
end

Then "I should be able to create an email configuration" do
  fill_in('Email', with: 'griphook@gringots.co.uk')
  fill_in('Username', with: 'Griphook')
  fill_in('Password', with: 'NeverMessWithGoblins')
  fill_in('Confirm password', with: 'NeverMessWithGoblins')

  click_on 'Create email configuration'
end

private

def email_configurations_table
  find '.pf-c-table[aria-label="Email configurations table"]'
end

def filter_email_config(value)
  input = find('input[aria-label="Search input"]')
  button = find('button[aria-label="Search"]')
  input.set(value)
  button.click
end
