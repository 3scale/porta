# frozen_string_literal: true

Given "my remote address is {string}" do |address|
  # This works only with RackTest driver.
  page.driver.browser.options.merge!({ headers: { 'REMOTE_ADDR' => address } })
end

When "I leave {string} blank" do |field|
  fill_in field, with: ''
end

Then "fields {} should be required" do |fields|
  fields.each do |field|
    assert page.has_xpath?("//label[text()='#{field}']/abbr[@title='required']"), "Field #{field} is not required"
  end
end

Then "I {should} see link to {link_to_page}" do |visible, path|
  assert_equal visible, (page.all('a').any? { |node| matches_path?(node[:href], path) })
end

# TODO: remove if the one above is good
# Then "I should not see {link_to_page}" do |path|
#   assert(page.all('a').none? { |node| matches_path?(node[:href], path) })
# end

#TODO: move this outta here!
def matches_path?(url, path)
  url =~ /^(?:https?:\/\/[^\/]+)?#{Regexp.quote(path)}/
end

Then "I should be redirected" do
  follow_redirect!
end

Then "I should be redirected to {string}" do |url|
  response.should redirect_to(url)
  follow_redirect!
end

Then "I should see within {string} the following:" do |selector, table|
  within selector do
    table.rows.flatten.each do |item|
      step %(I should see "#{item}")
    end
  end
end

# Then I should see "foo" and "bar"
# Then I should see "foo", "bar" and "baz"
# Then I should see "foo", "bar", "baz" and "qux"
# ...
Then "I {should} see #{QUOTED_TWO_OR_MORE_PATTERN}" do |visible, items|
  items.each do |item|
    step %(I should #{visible ? 'see' : 'not see'} "#{item}")
  end
end

Then "I should see the link {string} containing {string} in the URL" do |label, params|
  params = params.split
  href_contain_params = proc do |selector|
    params.each do |param|
      return false unless selector[:href].include? param
    end
  end
  assert page.has_css?('a', text: label, &href_contain_params)
end

Then "I {should} see the link {string}" do |visible, label|
  assert_equal visible, page.has_css?('a', text: label)
end

# Should not be neccesar
# Then "I {should} see the link {string} within {string}" do |visible, label, selector|
#   within selector do
#     assert_equal visible, page.has_css?('a', text: label)
#   end
# end

Then "I {should} see button {string}" do |visible, label|
  assert_equal visible, has_button?(label)
end

Then "I {should} see button {string} within {string}" do |visible, label, selector|
  within selector do
    step %(I should #{visible ? 'see' : 'not see'} button "#{label}")
  end
end

Then "the {string} select should not contain {string} option" do |label, text|
  select = find_field(label)
  assert select.all('option', text: text).empty?, %(The "#{label}" select should not contain "#{text}" option, but it does)
end

Then "the {string} select should have {string} selected" do |label, text|
  select = find_field(label)
  assert select.has_css?(%(option[selected]:contains("#{text}")))
end

Then "the {string} button should be hidden" do |label|
  assert has_css?('button', text: label, visible: false)
end

Then "I should see the fields contain:" do |table|
  table.rows_hash.each do |field, value|
    step %(the "#{field}" field should contain "#{value}")
  end
end

Then "I should see the fields:" do |table|
  table.rows.each do |field|
    step %(I should see field "#{field.first}")
  end
end

Then "I should see the fields in order:" do |table|
  page.html.should match /#{table.rows.map(&:first).map(&:downcase).join(".*")}/mi
end

Then "I should see field {string}" do |field|
  should have_field(field)
end

Then "I should not see the fields:" do |table|
  table.rows.each do |field|
    step %(I should not see field "#{field.first}")
  end
end

Then "I should not see field {string}" do |field|
  should_not have_field(field)
end

Then "I should see error {string} for field {string}" do |error, field|
  # This assumes the error is in a <p> element next to (sibling of) the input field.
  # Not sure if this will work in the general case.

  field = find_field(field)
  page.should have_css("##{field[:id]} ~ p", text: error)
end

Then "I {should} see image {string}" do |visible, file|
  assert_equal visible, all('img').any? do |image|
    File.basename(image[:src]) == file
  end
end

Then "I should see the following table:" do |table|
  table.diff!(extract_table('table', 'tr', 'th,td'))
end

Then "I should see {string} in the {string} column and {string} row" do |text, column, row|
  row_element = find(:xpath, "//td/a[text()=\"#{row}\"]/ancestor::tr")
  column_element = find(:xpath, "//th[text()='#{column}']")

  row_index = row_element.path.match(/^.*(\d)\]$/)[1]&.to_i
  column_index = column_element.path.match(/^.*(\d)\]$/)[1]&.to_i

  actual_text = find(:xpath, "//table/descendant::*/tr[#{row_index}]/td[#{column_index}]").text() if row_index && column_index

  assert_equal text, actual_text, "Expected #{text}, was #{actual_text}"
end

Then "I should see the following definition list:" do |table|
  # Not quite sure why single #next is not enought, possibly because
  # the first next sibling is just a text node?
  table.diff!(extract_table('dl', 'dt', ->(dt) { [dt, dt.next.next] }))
end

Then "I {should} see {string} column" do |visible, text|
  assert_equal visible, has_css?('thead th', text: text)
end

Then "the page title should be {string}" do |title|
  assert_equal page.body.match(/<title>(.*?)<\/title>/)[1], title
end

Then "I should see {string} in bold" do |text|
  assert has_css?('strong', text: text)
end

# this is being used only because of params[:type] in api/plans controller urls
# remove if that is not more used?
Then "(I )should be at url for {link_to_page}" do |path|
  current_path = URI.parse(current_url).request_uri
  if current_path.respond_to? :should
    current_path.should be path
  else
    assert_equal path, current_path
  end
end

# Finds a row witch contains the given content and restrict the action to that row.
#
#   Then I should see "foo" within the "bar" row
#
#   <table>
#     <tr> <-- the 'I should see "foo"' will be restricted to this row
#       <th>bar</th>
#       <td>foo</th>
#     </tr>
#   </table>
Then /^(.*) within the "([^"]*)" row$/ do |action, content|
  within(:xpath, "//*[text()[contains(.,'#{content}')]]/ancestor::tr") do
    step action
  end
end

When /^(.*) within ([^:"]+)$/ do |lstep, scope|
  within(*selector_for(scope)) do
    step lstep
  end
end

[ 'the audience dashboard widget', 'the apis dashboard widget',
  'the apis dashboard products widget', 'the apis dashboard backends widget',
  'the first api dashboard widget',
  'the main menu',
  'the subsubmenu','the user widget',
  'the footer', 'the account details box' ].each do |scope|
  When /^(.*) in (#{scope})$/ do |lstep, scope|
    within(*selector_for(scope)) do
      step lstep
    end
  end
end

# Multi-line version of above
When /^(.*) within ([^:"]+):$/ do |lstep, scope, table_or_string|
  within(selector_for(scope)) do
    step "#{lstep}:", table_or_string
  end
end

Then "take a snapshot" do
  page.driver.render Rails.root.join("tmp/capybara/#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.png")
end

Then "take a snapshot and show me the page" do
  step %(take a snapshot)
  step %(show me the page)
end

When "I reload the page" do
  case Capybara.current_driver
  when :selenium
    visit page.driver.browser.current_url
  when :racktest
    visit [ current_path, page.driver.last_request.env['QUERY_STRING'] ].reject(&:blank?).join('?')
  when :culerity
    page.driver.browser.refresh
  else
    raise "unsupported driver, use Rack::Test or selenium/webdriver"
  end
end


Then "I fill in {string} with file {string}" do |field, filename|
  file = fixture_file_upload(filename)
  attach_file(field, file.path)
end

Then "I should see file {string}" do |filename|
  expected = fixture_file_upload(filename).read
  assert_equal expected, page.driver.response.body # this works for rack-test
end

When "I visit {string}" do |path|
  visit path
end

And "I press {string} inside the dropdown" do |name|
  # binding.pry
  # Check this is equivalent:
  # link = XPath::HTML.link_or_button(name)
  link = find(:link, text: name) || find(:button, text: name)
  toggle = find :xpath, XPath.generate{ |x| x.css('.dropdown')[link].next_sibling(:a) }.to_s

  toggle.click
  find(:xpath, link).click
  wait_for_requests
end

toggled_input_selector = '[data-behavior="toggle-inputs"] legend'

And "I toggle {string}" do |name|
  find(toggled_input_selector, text: /#{name}/i).click
end

When "I toggle all inputs" do
  all(toggled_input_selector, visible: true).each(&:click)
end

When "I enter the admin password in {string}" do |field|
  step %(I fill in "#{field}" with "supersecret")
  step %(I press "Confirm Password")
end
