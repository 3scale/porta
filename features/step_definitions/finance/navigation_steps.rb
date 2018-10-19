When /^I navigate to (?:(\d)(?:nd|st|rd|th) )?invoice issued (?:for|FOR) me (?:for month|in) "([^\"]+)"$/ do |order,date|
  order ||= '1'

  # this is kind of hack as it supposes only 1 buyer!
  invoice_id = Time.zone.parse(date).strftime("%Y-%m-0000000#{order}")

  step %{I navigate to Invoices issued for me}
  step %(I should see "#{date}")
  step %(I follow "Show #{invoice_id}")
  step %(I should see "#{date}")
end

# TODO: remove this legacy step
When /^I navigate to [Ii]?nvoices issued (?:FOR|for) me$/ do
   if current_account.provider?
     step %(I go to my invoices from 3scale page)
   else
     step %(I go to my invoices)
   end
end

# TODO: remove this legacy step
When /^I navigate to invoices issued by me$/ do
  step %(I go to the invoices issued by me)
end

When /^I navigate to my (?:earnings|revenue)$/ do
  step %(I go to the invoices by months page)
end

When /^I navigate to invoices issued by me for "([^"]*)"$/ do |buyer_name|
  step %(I navigate to the page of the partner "#{buyer_name}")
  click_on('invoices', match: :one)
end

When /^I navigate to invoice (.*) issued by me for "([^"]*)"$/ do |invoice_number, buyer_name|
  step %(I navigate to invoices issued by me for "#{buyer_name}")

  row = page.find(%(tr:has(td:contains("#{invoice_number}"))))
  row.click_link("Show")
end
