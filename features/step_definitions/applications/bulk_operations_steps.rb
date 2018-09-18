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

When /^I (un)?check the first select in table body$/ do |un|
  within 'table.data tbody' do
    value = un.present? ? false : true

    first("input[type='checkbox'][name*='select']").set(value)
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

Then /^(all|none) selects should be checked$/ do |m|
  assert all('table.data tbody tr td.select input[type=checkbox]').send(m + '?', &:checked?)
end


And(/^close the colorbox$/) do
  find('#cboxClose').click
end
