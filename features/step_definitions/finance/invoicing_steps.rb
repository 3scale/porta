# frozen_string_literal: true

Given(/^an invoice of (buyer "[^"]*") for (\w+, *\d+)$/) do |buyer, month|
  create_invoice buyer, month
end

Given(/^I create a new invoice from the (?:API|UI) for this buyer for (\w+, *\d+) with:$/) do |month, items|
  invoice = create_invoice @buyer, month, creation_type: :manual
  items.hashes.each do |item|
    Finance::AdminBilling.new(invoice).create_line_item!(item)
  end
end

Given(/^an issued invoice of (buyer "[^"]*") for (\w+, *\d+)$/) do |buyer, month|
  invoice = create_invoice buyer, month
  invoice.issue_and_pay_if_free!
end

Given(/^an invoice of (buyer "[^"]*") for (\w+, *\d+) with items:?$/) do |buyer, month, items|
  invoice = create_invoice buyer, month
  items.hashes.each { |item| invoice.line_items.create!(item) }
end

Given "I issue the invoice number {string}" do |number|
  invoice = Invoice.by_number(number).first
  raise "No invoice with number '#{number}' found" unless invoice

  invoice.issue_and_pay_if_free!
end

Given "the buyer pays the invoice" do
  invoice = Invoice.last
  invoice.finalize
  invoice.issue
  invoice.pay
end

Given "the buyer pays the invoice but failed" do
  invoice = Invoice.last
  invoice.finalize
  invoice.issue
  invoice.mark_as_unpaid
  invoice.fail
end

Then "I should (still )see {int} invoice(s)" do |count|
  if count.zero?
    page.should have_no_css('tr.invoice')
  else
    page.should have_css('tr.invoice', count: count)
  end
end

Then "the buyer should have {int} invoice(s)" do |number|
  step 'the buyer logs in to the provider'
  step 'I navigate to invoices issued for me'

  step "I should see #{number} invoice"
end

Then /^the buyer should have following line items for "([^"]*)"(?: in the( \d(?:nd|st|rd|th)))? invoice:$/ do |date, order, items|
  step 'the buyer logs in to the provider'
  step 'I navigate to invoices issued for me'
  step %(I navigate to#{order} invoice issued for me in "#{date}")
  step 'I should see line items', items
end

Then "I should see the first invoice belonging to {string}" do |buyer|
  assert find(:xpath, '//table/tbody/tr[1]').text.include?(buyer)
end

Then "I should have {int} invoice(s)" do |count|
  step %(I navigate to invoices issued for me)
  step %(I should see #{count} invoices)
end

Then "I should see line items" do |items|
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
      line_name   = find(:xpath, "#{prefix}/th[1]").text.strip
      description = find(:xpath, "#{prefix}/td[1]").text.strip
      quantity    = find(:xpath, "#{prefix}/td[2]").text.strip
      real_cost   = find(:xpath, "#{prefix}/td[3]").text.strip

      assert_equal line['name'].squish,        line_name   unless line_name.blank?
      assert_equal line['description'].squish, description unless line['description'].blank?
      assert_equal line['quantity'].squish,    quantity    unless line['quantity'].blank?
      assert_match cost_regex,                 real_cost
    end
  end
end

Then "I should see invoice in state {string}" do |state|
  page.should have_css('dl', text: state.capitalize)
end

When "I see my invoice from {string} is {string}" do |month, state|
  step %(I navigate to invoice issued FOR me in "#{month}")
  step %(I should see invoice in state "#{state}")
end

Then "I should see secure PDF link for invoice {}" do |invoice_number|
  row = page.find(%(tr:has(td:contains("#{invoice_number}"))))
  link = row.find(%(td a:contains("PDF")))

  # This only checks that the link points to the s3 server and that it contains the
  # AWS secret id.
  #
  # REVIEW: Maybe check the full url is corret?
  assert_secure_invoice_pdf_url(link[:href], Invoice.find_by_friendly_id!(invoice_number))
end

Then "I should see secure PDF link for the shown buyer invoice" do
  link = page.find_link('PDF')

  id = link[:href].scan(%r{/invoices/(\d+)/}).join
  assert_secure_invoice_pdf_url(link[:href], Invoice.find(id))
end

Then "I should see secure PDF link for the shown invoice" do
  link = page.find_link('Download PDF')

  id = link[:href].scan(%r{/invoices/(\d+)/}).join
  assert_secure_invoice_pdf_url(link[:href], Invoice.find(id))
end

Then "I should have an invoice of \"{float} {}\"" do |amount, currency|
  invoices = Invoice.where(provider_account_id: current_account.id)
  assert invoices.select { |x| x.cost == amount && x.currency == currency }.any?
end

Given "an invoice of the buyer with a total cost of {int}" do |cost|
  step 'an invoice of buyer "bob" for January, 2011 with items:', table(<<-TABLE)
  | name   | cost |
  | Custom | #{cost} |
  TABLE
end

Then "I should see in the invoice period for the column {word} a cost of {float} {word}" do |column, cost, money|
  columns = ['month', 'total', 'in process', 'overdue', 'paid']
  position = columns.index(column) + 1
  node = find(:xpath, %(//table//td/a[text()="January, 2011"]/../..//td[#{position}]))
  assert_equal "#{money} #{cost}", node.text
end

Then "there is only one invoice for {string}" do |date|
  step 'the buyer logs in to the provider'
  step 'I navigate to invoices issued for me'
  nodes = page.find_all(:xpath, ".//tr[contains(@class,'invoice')]/td[contains(text(), '#{date}')]")
  assert_equal 1, nodes.count
end
