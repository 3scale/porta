# frozen_string_literal: true

# Create a list of invoices.
# State can be: 'unpaid', 'pending', 'paid', 'finalized'.
#
#   And the following invoices:
#     | Buyer | Month          | Friendly ID      | State | Total cost |
#     | Jane  | December, 2010 | 2011-01-00000001 | Paid  | 20.00      |
#     | Jane  | January, 2011  | 2011-01-00000002 | Open  |            |
#
Given "the following invoice(s):" do |table|
  transform_invoices_table(table)
  table.hashes.each do |options|
    buyer = options[:buyer_account]
    options[:provider_account] = buyer.provider_account
    total_cost = options.delete('total_cost')

    invoice = FactoryBot.create(:invoice, :skip_validations, options.reverse_merge(creation_type: :background))

    FactoryBot.create(:line_item, invoice: invoice, name: 'Custom', cost: total_cost) if total_cost.present?
  end
end

# TODO: remove this, use "the following invoices:"
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

# Creates an invoice for a given account at a given time, with line items.
#
#   Given the buyer has an invoice for February, 2009 with the following items:
#     | Name    | Description     | Quantity | Cost |
#     | Bananas | A bunch of them | 1        | 42   |
#
Given "{buyer} has an invoice for {date} with the following item(s):" do |buyer, month, items|
  @invoice = FactoryBot.create(:invoice, provider_account: buyer.provider_account,
                                         buyer_account: buyer)
  line_items = @invoice.line_items

  parameterize_headers(items)
  items.hashes.each { |item| line_items.create!(item) }
end

Given "an invoice of {buyer} for {date} with items(:)" do |buyer, month, items|
  ActiveSupport::Deprecation.warn '[Cucumber] Deprecated! Use the newer step.'
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
    should have_no_xpath("//tr[contains(@id, 'invoice_')]")
  else
    should have_xpath("//tr[contains(@id, 'invoice_')]", count: count.to_i)
  end
end

Then /^the buyer should have (\d+) invoices?$/ do |number|
  set_current_domain @provider.external_domain
  try_buyer_login_internal(@buyer.admins.first.username, "supersecret")
  visit admin_account_invoices_path

  assert_selector(:css, 'tr.invoice', count: number.to_i)
end

Then /^the buyer should have following line items for "([^"]*)"(?: in the (\d)(?:nd|st|rd|th))? invoice:$/ do |date, order, items|
  ActiveSupport::Deprecation.warn '[Cucumber] Deprecated! Assert table instead.'
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

Then(/^I should have (\d+) invoices?$/) do |count|
  assert_equal count, current_account.invoices.visible_for_buyer.size
end

# TODO: change to accept REGEXPs! (use page.body and assert)
Then(/^I should see line items$/) do |items|
  ActiveSupport::Deprecation.warn '[Cucumber] Deprecated! Assert table instead.'
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

Then "there should be a secure link to download the PDF of invoice {string}" do |invoice_number|
  link = find('tr.invoice', text: invoice_number).find('td a', text: 'PDF')

  # This only checks that the link points to the s3 server and that it contains the
  # AWS secret id.
  #
  # REVIEW: Maybe check the full url is corret?
  assert_secure_invoice_pdf_url(link[:href], Invoice.find_by!(friendly_id: invoice_number))
end

Then "there should be a secure link to download the PDF" do
  link = page.find_link('PDF')

  id = link[:href].scan(%r{/invoices/(\d+)/}).join
  assert_secure_invoice_pdf_url(link[:href], Invoice.find(id))
end

Then(/^I should have an invoice of "(\d+\.?\d*) (.+)"$/) do |amount, currency|
  invoices = Invoice.where(provider_account_id: current_account.id)
  assert invoices.select { |x| x.cost.to_s == amount && x.currency == currency }.any?
end

Then(/there is only one invoice for "([^"]*)"/) do |date|
  set_current_domain @provider.external_domain
  try_buyer_login_internal(@buyer.admins.first.username, "supersecret")
  visit admin_account_invoices_path
  nodes = page.find_all(:xpath, ".//tr[contains(@class,'invoice')]/td[contains(text(), '#{date}')]")
  assert_equal 1, nodes.count
end

Then "invoices can be filtered by the following years:" do |table|
  select_attribute_filter('Year')

  select = find('[data-ouia-component-id="attribute-search"] .pf-c-select[data-ouia-component-id="Filter by year"]')
  select.click
  actual_years = select.find_all('ul .pf-c-select__menu-item', wait: 0).map(&:text)
  expected_years = table.raw.flatten.map(&:to_s)
  assert_same_elements expected_years, actual_years
end

Given "buyers of {provider} have no invoices" do |provider|
  assert_empty provider.buyer_invoices
end

Given "{provider} has no invoices" do |provider|
  assert_empty provider.buyer_invoices
end

Then "the total cost is/should( be) {string}" do |cost_with_currency|
  assert_equal cost_with_currency, find('table.invoice tfoot tr td#invoice_cost').text
end
