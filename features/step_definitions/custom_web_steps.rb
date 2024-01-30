# frozen_string_literal: true

Then "(I )(they )should see (a )(the )link to {}" do |page_name|
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

Then(/^I should see within "([^"]*)" the following:$/) do |selector, table|
  within selector do
    table.rows.flatten.each do |item|
      step %(I should see "#{item}")
    end
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

Then /^(?:I )?should see (the |)link "([^"]*)"$/ do |_, label|
  assert page.has_css?('a', :text => label)
end

Then /^I should not see (?:the )?link "([^"]*)"$/ do |label|
  assert page.has_no_xpath? ".//a[text()='#{label}']"
end

Then "there {should} be a button to {string}" do |visible, label|
  assert_equal visible, has_button?(label)
end

Then "there {should} be a link to {string}" do |visible, label|
  assert_equal visible, has_link?(label)
end

Then(/^I should see button "([^"]*)"( disabled)?$/) do |label, disabled|
  assert find_button(label, disabled: disabled.present?)
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

Then /^I should see error "([^"]*)" for field "([^"]*)"$/ do |error, field|
  # This assumes the error is in a <p> element next to (sibling of) the input field.
  # Not sure if this will work in the general case.

  field = find_field(field)
  page.should have_css("##{field[:id]} ~ p", :text => error)
end

Then /^I should see "([^"]*)" in the "([^"]*)" column and "([^"]*)" row$/ do |text, column, row|
  if has_css?('table.pf-c-table')
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

When /^(.*) within ([^:"]+)$/ do |lstep, scope|
  within(*selector_for(scope)) do
    step lstep
  end
end

When /^(.*) within ([^:"]+):$/ do |lstep, scope, table|
  within(*selector_for(scope)) do
    step(lstep, table)
  end
end

When /^(.*) that belongs to ([^:]+)$/ do |lstep, scope|
  within(*selector_for(scope)) do
    step lstep
  end
end

[ 'the audience dashboard widget', 'the apis dashboard widget',
  'the main menu' ].each do |scope|
  When /^(.*) in (#{scope})$/ do |lstep, scope|
    within(*selector_for(scope)) do
      step lstep
    end
  end
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

Then "the following warning should be visible:" do |doc_string|
  assert has_css?('.pf-c-alert.pf-m-warning', text: doc_string.tr("\n", ' '))
end

Then "there should not be any wanrning" do
  assert has_no_css?('.pf-c-alert.pf-m-warning', wait: 0)
end
