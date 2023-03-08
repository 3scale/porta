# frozen_string_literal: true

Then "they should not be able to see any invoices" do
  assert_raise(Capybara::ElementNotFound) { invoices_tab }
  visit admin_account_invoices_path
  assert_text 'Access Denied'
end

Then "they should be able to see an invoice for last month" do
  invoices_tab.click
  assert admin_account_invoices_path, current_path

  invoices = find_all('tr.invoice')

  assert_equal 1, invoices.length
  assert invoices.first.has_text?(Time.zone.now.last_month.strftime('%B, %Y'))
end

Then /^the buyer should receive (no|some) emails$/ do |amount|
  email_queue = unread_emails_for(@buyer.emails.first)

  case amount
  when 'no' then assert_empty(email_queue)
  when 'some' then assert_equal 4, email_queue.size # Invoice notice plus 3 failed charging attempts
  end
end

def invoices_tab
  find('.nav-tabs li a', text: 'Invoices')
end
