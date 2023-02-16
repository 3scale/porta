# frozen_string_literal: true

Given /^a following buyers with applications exists:$/ do |buyers|
  buyers.hashes.each do |buyer|
    step %{a buyer "#{buyer['name']}" signed up to provider "#{buyer['provider']}"}
    buyer['applications'].from_sentence.each do |application|
      step %{buyer "#{buyer['name']}" has application "#{application}"}
    end
  end
end

def check_or_uncheck_selected_row value, text = nil
  set =  value.present? ? false : true

  selector = if text
    [:xpath, "//tbody/tr/td[*[text() = #{text.inspect}] | text() = #{text.inspect}]/preceding-sibling::td//input[@type='checkbox' and contains(@name,'select')]"]
             else
    "input[type='checkbox'][name*='select']"
  end

  all(*selector).each do |checkbox|
    checkbox.set(set)
  end
end

When /^I (un)?check select for "(.+?)"$/ do |un, name|
  names = name.from_sentence.map{|n| n.delete('"') }
  names.each do |name|
    check_or_uncheck_selected_row un, name
  end
end

When /^I (un)?check select in table header$/ do |un|
  within 'table.data thead' do
    check_or_uncheck_selected_row un
  end
end

And(/^close the colorbox$/) do
  find('#cboxClose').click
end

When "the application will return an error when suspended" do
  Cinstance.any_instance.stubs(:suspend).returns(false).once
end

When "the application will return an error when plan changed" do
  Cinstance.any_instance.stubs(:change_plan).returns(false).once
end

When "I should see the bulk action failed with {application}" do |application|
  assert_match "There were some errors:\n#{application.name} (#{application.user_account.org_name})", bulk_errors_container.text
end
