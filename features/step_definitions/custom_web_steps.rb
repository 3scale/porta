# frozen_string_literal: true

#DEPRECATED: replace with <<there should( not| n't)? be a link to ([^"]*)>>
Then "(I )(they )should see (a )(the )link to {}" do |page_name|
  ActiveSupport::Deprecation.warn 'replace with <<there should( not| n\'t)? be a link to ([^"]*)>>'
  path = path_to(page_name)
  assert page.all('a').any? { |node| matches_path?(node[:href], path) }
end

#DEPRECATED: replace with <<there should( not| n't)? be a link to ([^"]*)>>
Then /^I should not see link to (.+)$/ do |page_name|
  ActiveSupport::Deprecation.warn 'replace with <<there should( not| n\'t)? be a link to ([^"]*)>>'
  path = path_to(page_name)
  assert page.all('a').none? { |node| matches_path?(node[:href], path) }
end

#TODO: move this outta here!
def matches_path?(url, path)
  url =~ /^(?:https?:\/\/[^\/]+)?#{Regexp.quote(path)}/
end

#DEPRECATED: replace with <<there should( not| n't)? be a link to ([^"]*)>>
Then /^I should see (?:|the )link "([^"]*)" containing "([^"]*)" in the URL$/ do |label, params|
  ActiveSupport::Deprecation.warn 'replace with <<there should( not| n\'t)? be a link to ([^"]*)>>'
  params = params.split
  href_contain_params = proc do |selector|
    params.each do |param|
      return false unless selector[:href].include? param
    end
  end
  assert page.has_css?('a', :text => label, &href_contain_params)
end

#DEPRECATED: replace with "there {should} be a link to {string}"
Then /^(?:I )?should see (the |)link "([^"]*)"$/ do |_, label|
  ActiveSupport::Deprecation.warn 'replace with "there {should} be a link to {string}"'
  assert page.has_css?('a', :text => label)
end

#DEPRECATED: replace with "there {should} be a link to {string}"
Then /^I should not see (?:the )?link "([^"]*)"$/ do |label|
  ActiveSupport::Deprecation.warn 'replace with "there {should} be a link to {string}"'
  assert page.has_no_xpath? ".//a[text()='#{label}']"
end

# Assert whether a button with a certain label is visible in the current page.
#
# Examples:
#   Then there should be a button to "Plans"
#   Then there should not be a button to "Create a plan"
#   Then there shouldn't be a button to "Dashboard"
#
Then "there {should} be a button to {string}" do |visible, label|
  assert public_send(visible ? :has_button? : :has_no_button?, label)
end

# Assert whether a link with a certain label is visible in the current page.
#
# Examples:
#   Then there should be a link to "Plans"
#   Then there should not be a link to "Create a plan"
#   Then there shouldn't be a link to "Dashboard"
#
Then "there {should} be a link to {string}" do |visible, label|
  assert public_send(visible ? :has_link? : :has_no_link?, label)
end

# Assert whether a link to a certain href is visible in the current page. The href is looked up from
# "paths.rb" by name.
#
# Examples:
#   Then there should be a link to the plans index page
#   Then there should not be a link to the new plan page
#   Then there shouldn't be a link to the provider dashboard
#
Then /^there should( not| n't)? be a link to ([^"]*)$/ do |invisible, page_name|
  visible = invisible.nil?
  path = path_to(page_name)
  assert_equal visible, has_link?(href: path, wait: visible)
end

Then(/^(?:|I |they )should see button "([^"]*)"( disabled| enabled)?$/) do |label, condition|
  assert find_button(label, disabled: condition == ' disabled')
end

Then /^I should not see button "([^\"]*)"$/ do |label|
  assert has_no_button?(label)
end

Then /^the "([^"]*)" select should have "([^"]*)" selected$/ do |label, text|
  select = find_field(label)
  assert select.has_css?(%(option[selected]:contains("#{text}")))
end

Then "(I )(they ){should} see the fields:" do |visible, table|
  assert(table.raw.flatten.all? { |field| has_field?(field, wait: 0) == visible })
end

Then "(I )(they ){should} see field {string}" do |visible, field|
  assert_equal visible, has_field?(field, wait: 0)
end

Then "I/they should see the fields in order:" do |table|
  page.html.should match /#{table.rows.map(&:first).map(&:downcase).join(".*")}/mi
end

# DEPRECATED: replace with field {string} has inline error {string}
Then /^I should see error "([^"]*)" for field "([^"]*)"$/ do |error, field|
  # This assumes the error is in a <p> element next to (sibling of) the input field.
  # Not sure if this will work in the general case.

  field = find_field(field)
  page.should have_css("##{field[:id]} ~ p", :text => error)
end

Then /^I should see "([^"]*)" in the "([^"]*)" column and "([^"]*)" row$/ do |text, column, row|
  if has_css?('table.pf-c-table', wait: 0)
    column_values = find_all("td[data-label='#{column}'").map(&:text)
    rows = find_all('tbody tr td[data-label="Group/Org."]')
    index = rows.find_index{ |r| r.text == row }

    actual_text = column_values[index]
  else
    # DEPRECATED: remove when all tables use Patternfly
    row_element = find(:xpath, "//td/a[text()=\"#{row}\"]/ancestor::tr")
    column_element = find(:xpath, "//th[text()='#{column}']")

    row_index = row_element.path.match(/^.*(\d)\]$/)[1]&.to_i
    column_index = column_element.path.match(/^.*(\d)\]$/)[1]&.to_i

    actual_text = find(:xpath, "//table/descendant::*/tr[#{row_index}]/td[#{column_index}]").text() if row_index && column_index
  end
  assert_equal text, actual_text, "Expected #{text}, was #{actual_text}"
end

Then /^I should not see "([^"]*)" column$/ do |text|
  assert has_no_css?('thead th', :text => text)
end

Then /^I should see "([^\"]*)" in bold$/ do |text|
  assert_selector(:css, 'strong', :text => text)
end

# this is being used only because of params[:type] in api/plans controller urls
# remove if that is not more used?
Then /^(?:|I |they )should be at url for (.+)$/ do |page_name|
  current_path = URI.parse(current_url).request_uri
  if current_path.respond_to? :should
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
  end
end

Then "they should be able to go to {page}" do |path|
  visit path
  assert_current_path path
end

Then "they should be able to go to the following pages:" do |table|
  table.raw.flatten.each do |page|
    path = path_to(page)
    visit path
    assert_current_path path
  end
end

# Confine any one step within a specific css selector from features/support/selectors.rb
# Due to incompatibilities (FIXME?) this step do not support selectors with double quotes. If the
# desired selector has double quotes, use the "belongs to" step instead.
#
#   When they follow "Application 001" within the table body
#   Then should see the following table within the features:
#     | Name         | Description                                |
#     | Free T-shirt | T-shirt with logo of our company for free. |
#
When /^(.*) within ([^:"]+)$/ do |lstep, scope|
  within(*selector_for(scope)) do
    step(lstep)
  end
end

# Same as above, but with a data-table.
#
When /^(.*) within ([^:"]+):$/ do |lstep, scope, table|
  within(*selector_for(scope)) do
    step(lstep, table)
  end
end

# Confine any one step within a specific css selector from features/support/selectors.rb
# This step supports selectors with double quotes.
#
#   When they follow "Delete" that belongs to application key "key-1"
#   Then should see the following table that belongs to metric "Hits" usage limits:
#     | Period   | Value |
#     | 1 minute | 10    |
#
When /^(.*) that belongs to ([^:]+)$/ do |lstep, scope|
  within(*selector_for(scope)) do
    step(lstep)
  end
end

# Same as above, but with a data-table.
#
When /^(.*) that belongs to ([^:]+):$/ do |lstep, scope, table|
  within(*selector_for(scope)) do
    step(lstep, table)
  end
end

When /^(?:|I |they )visit "(.+?)"$/ do |path|
  visit path
end

toggled_input_selector = '[data-behavior="toggle-inputs"] legend'

And(/^I toggle "([^"]*)"$/) do |name|
  find(toggled_input_selector, text: /#{name}/i).click
end

Then "the following warning should be visible:" do |doc_string|
  assert has_css?('.pf-c-alert.pf-m-warning', text: doc_string.tr("\n", ' '))
end

Then "there should not be any wanrning" do
  assert has_no_css?('.pf-c-alert.pf-m-warning', wait: 0)
end
