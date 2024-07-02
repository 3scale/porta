# frozen_string_literal: true

# TODO: Legacy, replace with path_to: when /^the 3scale invoices for "(\w+, \d{4})"$/
When /^I navigate to (?:(\d)(?:nd|st|rd|th) )?invoice issued (?:for|FOR) me (?:for month|in) "([^\"]+)"$/ do |order,date|
  order ||= '1'

  # this is kind of hack as it supposes only 1 buyer!
  invoice_id = Time.zone.parse(date).strftime("%Y-%m-0000000#{order}")

  if current_account.provider?
    visit provider_admin_account_invoices_path
  else
    visit admin_account_invoices_path
  end

  assert_page_has_content date
  click_link "Show #{invoice_id}"
  assert_page_has_content date
end

# TODO: remove this legacy step
When /^I navigate to [Ii]?nvoices issued (?:FOR|for) me$/ do
   if current_account.provider?
     visit provider_admin_account_invoices_path
   else
     visit admin_account_invoices_path
   end
end
