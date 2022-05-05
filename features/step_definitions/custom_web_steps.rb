# frozen_string_literal: true

#TODO: is this a web step anyway?
Given /^my remote address is "([^"]*)"$/ do |address|
  # This works only with RackTest driver.
  page.driver.browser.options.merge!({:headers => {'REMOTE_ADDR' => address }})
end

When /^I leave "([^\"]*)" blank$/ do |field|
  fill_in field, :with => ''
end

Then /^fields (.*) should be required$/ do |fields|
  fields.each do |field|
    assert page.has_xpath?("//label[text()='#{field}']/abbr[@title='required']"),
           "Field #{field} is not required"
  end
end

Then /^I should see link to (.+)$/ do |page_name|
  path = path_to(page_name)
  assert page.all('a').any? { |node| matches_path?(node[:href], path) }
end

Then /^I should not see link to (.+)$/ do |page_name|
  path = path_to(page_name)
  assert page.all('a').none? { |node| matches_path?(node[:href], path) }
end

#TODO: move this outta here!
def matches_path?(url, path)
  url =~ /^(?:https?:\/\/[^\/]+)?#{Regexp.quote(path)}/
end

Then /^I should be redirected$/ do
  follow_redirect!
end

Then /^I should be redirected to "([^\"]*)"$/ do |url|
  response.should redirect_to(url)
  follow_redirect!
end

Then(/^I should see within "([^"]*)" the following:$/) do |selector, table|
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
Then "I should {word} {list_of_2_plus_strings}" do |action, items|
  items.each do |item|
    step %(I should #{action} "#{item}")
  end
end

#TODO: turn steps into the use of the 'the'
Then /^I should see (?:|the )link "([^"]*)" containing "([^"]*)" in the URL$/ do |label, params|
  params = params.split
  href_contain_params = proc do |selector|
    params.each do |param|
      return false unless selector[:href].include? param
    end
  end
  assert page.has_css?('a', :text => label, &href_contain_params)
end

Then /^I should see (the |)link "([^"]*)"$/ do |_, label|
  assert page.has_css?('a', :text => label)
end

Then /^I should see link "([^"]*)" within "([^"]*)"$/ do |label, selector|
  within selector do
    assert page.has_css?('a', :text => label)
  end
end

Then /^I should not see (?:the )?link "([^"]*)"$/ do |label|
  assert page.has_no_xpath? ".//a[text()='#{label}']"
end

Then /^I should not see link "([^"]*)" within "([^"]*)"$/ do |label, selector|
  within selector do
    assert has_no_css?('a', :text => label)
  end
end

Then(/^I should see button "([^"]*)"( disabled)?$/) do |label, disabled|
  assert find_button(label, disabled: disabled.present?)
end

Then /^I should not see button "([^\"]*)"$/ do |label|
  assert has_no_button?(label)
end

Then /^I should not see button "([^\"]*)" within "([^"]*)"$/ do |label, selector|
  if has_css?(selector)
    within selector do
      assert has_no_button?(label)
    end
  end
end

Then /^the "([^"]*)" select should not contain "([^"]*)" option$/ do |label, text|
  assert_select_not_inclues_option(label, text)
end

Then /^the "([^"]*)" select should have "([^"]*)" selected$/ do |label, text|
  select = find_field(label)
  assert select.has_css?(%(option[selected]:contains("#{text}")))

end

Then /^the "([^"]*)" button should be hidden$/ do |label|
  assert has_css?('button', :text => label, :visible => false)
end

Then /^I should see the fields contain:$/ do |table|
  table.rows_hash.each do |field, value|
    step %{the "#{field}" field should contain "#{value}"}
  end
end

Then /^I should see the fields:$/ do |table|
  table.rows.each do |field|
    step %{I should see field "#{field.first}"}
  end
end

Then /^I should see the fields in order:$/ do |table|
  page.html.should match /#{table.rows.map(&:first).map(&:downcase).join(".*")}/mi
end

Then /^I should see field "([^\"]*)"$/ do |field|
  should have_field(field)
end

Then /^I should not see the fields:$/ do |table|
  table.rows.each do |field|
    step %{I should not see field "#{field.first}"}
  end
end

Then /^I should not see field "([^"]*)"$/ do |field|
  should_not have_field(field)
end

Then /^I should see error "([^"]*)" for field "([^"]*)"$/ do |error, field|
  # This assumes the error is in a <p> element next to (sibling of) the input field.
  # Not sure if this will work in the general case.

  field = find_field(field)
  page.should have_css("##{field[:id]} ~ p", :text => error)
end

Then /^I should see image "([^"]*)"$/ do |file|
  assert(all('img').any? do |image|
    File.basename(image[:src]) == file
  end)
end

Then /^I should not see image "([^"]*)"$/ do |file|
  assert(all('img').none? do |image|
    File.basename(image[:src]) == file
  end)
end

Then /^I should see "([^"]*)" in the "([^"]*)" column and "([^"]*)" row$/ do |text, column, row|
  row_element = find(:xpath, "//td/a[text()=\"#{row}\"]/ancestor::tr")
  column_element = find(:xpath, "//th[text()='#{column}']")

  row_index = row_element.path.match(/^.*(\d)\]$/)[1]&.to_i
  column_index = column_element.path.match(/^.*(\d)\]$/)[1]&.to_i

  actual_text = find(:xpath, "//table/descendant::*/tr[#{row_index}]/td[#{column_index}]").text() if row_index && column_index

  assert_equal text, actual_text, "Expected #{text}, was #{actual_text}"
end

Then /^I should see the following definition list:$/ do |table|
  # Not quite sure why single #next is not enought, possibly because
  # the first next sibling is just a text node?
  table.diff!(extract_table('dl', 'dt', ->(dt) { [dt, dt.next.next] }))
end

Then /^I should not see "([^"]*)" column$/ do |text|
  assert has_no_css?('thead th', :text => text)
end

Then /^the page title should be "([^"]*)"$/ do |title|
  assert_equal page.body.match(/<title>(.*?)<\/title>/)[1], title
end

Then /^I should see "([^\"]*)" in bold$/ do |text|
  assert has_css?('strong', :text => text)
end

# this is being used only because of params[:type] in api/plans controller urls
# remove if that is not more used?
Then /^(?:|I )should be at url for (.+)$/ do |page_name|
  current_path = URI.parse(current_url).request_uri
  if current_path.respond_to? :should
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
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


Then /take a snapshot(| and show me the page)/ do |show_me|
  page.driver.render Rails.root.join("tmp/capybara/#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.png")
  step %{show me the page} if show_me.present?
end

When /^I reload the page$/ do
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


Then /^I fill in "(.+?)" with file "(.+?)"$/ do |field, filename|
  file = fixture_file_upload(filename)
  attach_file(field, file.path)
end

Then /^I should see file "(.+?)"$/ do |filename|
  expected = fixture_file_upload(filename).read
  assert_equal expected, page.driver.response.body # this works for rack-test
end

When /^I visit "(.+?)"$/ do |path|
  visit path
end


And(/^I press "Hide" inside the dropdown$/) do
  find(:button, text: 'Publish').sibling('a').click
  find(:button, name: 'hide').click
  wait_for_requests
end

toggled_input_selector = '[data-behavior="toggle-inputs"] legend'

And(/^I toggle "([^"]*)"$/) do |name|
  find(toggled_input_selector, text: /#{name}/i).click
end

When(/^I toggle all inputs$/) do
  all(toggled_input_selector, visible: true).each(&:click)
end

When(/^I enter the admin password in "([^"]+)"$/) do |field|
  step %(I fill in "#{field}" with "supersecret")
  step %(I press "Confirm Password")
end

def assert_select_not_inclues_option(label, text)
  if page.has_css?('.pf-c-form__label', text: label)
    select = find('.pf-c-form__label', text: label).sibling('.pf-c-select')
    select.find('.pf-c-select__toggle-button').click
    selector = '.pf-c-select__menu-item'
  else
    # DEPRECATED: remove when all selects have been replaced for PF4
    ThreeScale::Deprecation.warn "[cucumber] Detected a select not using PF4 css"
    selector = 'option'
    select = find_field(label)
  end
  assert select.all(selector, text: text).empty?, %(The "#{label}" select should not contain "#{text}" option, but it does)
end
