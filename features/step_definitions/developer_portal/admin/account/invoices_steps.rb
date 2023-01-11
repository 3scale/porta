# frozen_string_literal: true

Then "they should not be able to see any invoices" do
  assert_raise(Capybara::ElementNotFound) { invoices_tab }
  visit admin_account_invoices_path
  assert_text 'Access Denied'
end

Then "they should be able to see their invoices" do
  invoices_tab.click
  assert admin_account_invoices_path, current_path
end

Then /^the buyer should receive (no|some) emails after a month$/ do |amount|
  reset_mailer
  time_machine(1.send(:month).from_now)
  email_queue = unread_emails_for(@buyer.emails.first)

  case amount
  when 'no' then assert_empty(email_queue)
  # FIXME: fix the date or something so that it's always 4
  when 'some' then assert_includes [3, 4], email_queue.size # Invoice notice plus 3 or 4 failed charging attempts depending on date
  end
end

def invoices_tab
  find('.nav-tabs li a', text: 'Invoices')
end
