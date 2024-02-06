# frozen_string_literal: true

Given "an invoice of {buyer} for {date}" do |buyer, date|
  create_invoice buyer, date
end

Given "I create a new invoice from the API for this buyer for {date} with:" do |month, items|
  invoice = create_invoice @buyer, month, creation_type: :manual
  items.hashes.each do |item|
    Finance::AdminBilling.new(invoice).create_line_item!(item)
  end
end

Given "an issued invoice of {buyer} for {date}" do |buyer, month|
  invoice = create_invoice buyer, month
  invoice.issue_and_pay_if_free!
end

Given "an invoice of {buyer} for {date} with items(:)" do |buyer, month, items|
  invoice = create_invoice buyer, month
  items.hashes.each { |item| invoice.line_items.create!(item) }
end

# TODO: add more actions if needed
Given(/^I issue the invoice number "(.*?)"$/) do |number|
  invoice = Invoice.by_number(number).first
  if invoice
    invoice.issue_and_pay_if_free!
  else
    raise "No invoice with number '#{number}' found"
  end
end

Given(/^the buyer pays the invoice$/) do
  invoice = Invoice.last
  invoice.finalize
  invoice.issue
  invoice.pay
end

Given(/^the buyer pays the invoice but failed$/) do
  invoice = Invoice.last
  invoice.finalize
  invoice.issue
  invoice.mark_as_unpaid
  invoice.fail
end

Then(/^I should (?:see|still see) (\d+) invoices?$/) do |count|
  if count.to_i == 0
    page.should have_no_css('tr.invoice')
  else
    page.should have_css('tr.invoice', count: count.to_i)
  end
end

Then /^the buyer should have (\d+) invoices?$/ do |number|
  set_current_domain @provider.external_domain
  try_buyer_login_internal(@buyer.admins.first.username, "supersecret")
  visit admin_account_invoices_path

  assert_selector(:css, 'tr.invoice', count: number.to_i)
end

Then /^the buyer should have following line items for "([^"]*)"(?: in the (\d)(?:nd|st|rd|th))? invoice:$/ do |date, order, items|
  set_current_domain @provider.external_domain
  try_buyer_login_internal(@buyer.admins.first.username, "supersecret")
  visit admin_account_invoices_path

  order ||= '1'

  # this is kind of hack as it supposes only 1 buyer!
  invoice_id = Time.zone.parse(date).strftime("%Y-%m-0000000#{order}")

  visit admin_account_invoices_path
  assert_page_has_content date
  click_link "Show #{invoice_id}"
  assert_page_has_content date

  assert_line_items(items)
end

Then(/^I should see the first invoice belonging to "([^"]*)"$/) do |buyer|
  assert_selector(:css, 'table tbody tr.invoice td[data-label="Account"]', text: buyer)
end

Then(/^I should have (\d+) invoices?$/) do |count|
  assert_equal count, current_account.invoices.visible_for_buyer.size
end

# TODO: change to accept REGEXPs! (use page.body and assert)
Then(/^I should see line items$/) do |items|
  assert_line_items(items)
end

def assert_line_items(items)
  items.hashes.each_with_index do |line, i|
    name = line['name']
    cost = line['cost']
    cost = /#{cost}\./ unless cost.include?('.')

    cost_regex = /^EUR\p{Separator}#{cost}/

    case name.strip
    when /Total cost \(without VAT\)/
      invoice_cost_without_vat = find(:xpath, "//td[@id='invoice_cost_without_vat']").text.strip

      assert_match cost_regex, invoice_cost_without_vat
    when /Total cost.*/
      invoice_cost = find(:xpath, "//td[@id='invoice_cost']").text.strip

      assert_match cost_regex, invoice_cost
    when /Total VAT Amount/
    else
      prefix      = "//table[@id='line_items']/tbody/tr[#{i + 1}]"
      line_name   = find(:xpath, "#{prefix}/*[1]").text.strip
      description = find(:xpath, "#{prefix}/*[2]").text.strip
      quantity    = find(:xpath, "#{prefix}/*[3]").text.strip
      real_cost   = find(:xpath, "#{prefix}/*[4]").text.strip

      # TODO: strip double whitespace as done in https://github.com/3scale/system/commit/ce72abe4d673b1592f96ed9532c62317306c7ea6
      assert_equal line['name'], line_name unless line_name.blank?
      assert_equal line['description'], description unless line['description'].blank?
      assert_equal line['quantity'],    quantity    unless line['quantity'].blank?
      assert_match cost_regex,          real_cost
    end
  end
end

Then(/^I should see invoice in state "([^"]*)"$/) do |state|
  page.should have_css('dl', text: state.capitalize)
end

When(/^I see my invoice from "([^"]*)" is "([^"]*)"$/) do |month, state|
  visit admin_account_invoices_path
  click_link "Show #{Time.zone.parse(month).strftime('%Y-%m-00000001')}"
  page.should have_css('dl', text: state.capitalize)
end

Then(/^I should see secure PDF link for invoice (.*)$/) do |invoice_number|
  link = find('tr.invoice', text: invoice_number).find('td a', text: 'PDF')

  # This only checks that the link points to the s3 server and that it contains the
  # AWS secret id.
  #
  # REVIEW: Maybe check the full url is corret?
  assert_secure_invoice_pdf_url(link[:href], Invoice.find_by!(friendly_id: invoice_number))
end

Then(/^I should see secure PDF link for the shown (buyer )?invoice$/) do |buyer_side|
  link = buyer_side ? page.find_link('PDF') : page.find_link('Download PDF')

  id = link[:href].scan(%r{/invoices/(\d+)/}).join
  assert_secure_invoice_pdf_url(link[:href], Invoice.find(id))
end

Then(/^I should have an invoice of "(\d+\.?\d*) (.+)"$/) do |amount, currency|
  invoices = Invoice.where(provider_account_id: current_account.id)
  assert invoices.select { |x| x.cost.to_s == amount && x.currency == currency }.any?
end

Given(/^an invoice of the buyer with a total cost of (\d+)/) do |cost|
  date = Time.zone.now.strftime('%B, %Y')
  invoice = create_invoice(@buyer, date)
  invoice.line_items.create!({ name: 'Custom', cost: cost })
end

Then(/^I should see in the invoice period for the column "(in process|overdue|paid|total)" a cost of (\d+\.\d+) (\w+)$/) do |column, cost, money|
  columns = ['month', 'total', 'in process', 'overdue', 'paid']
  position = columns.index(column) + 1
  date = Time.zone.now.strftime('%B, %Y')
  node = find(:xpath, %(//table//td/a[text()="#{date}"]/../..//td[#{position}]))
  assert_equal "#{money} #{cost}", node.text
end

Then(/there is only one invoice for "([^"]*)"/) do |date|
  set_current_domain @provider.external_domain
  try_buyer_login_internal(@buyer.admins.first.username, "supersecret")
  visit admin_account_invoices_path
  nodes = page.find_all(:xpath, ".//tr[contains(@class,'invoice')]/td[contains(text(), '#{date}')]")
  assert_equal 1, nodes.count
end

Then "invoices can be filtered by the following years:" do |table|
  actual_years = find('#search_year').find_all('option').map(&:value).map(&:to_s)
  expected_years = table.raw.flatten.map(&:to_s)
  assert_same_elements expected_years, actual_years
end

Given "{buyer} has no invoices" do |buyer|
  assert_empty buyer.invoices
end
