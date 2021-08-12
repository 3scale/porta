# frozen_string_literal: true

Given "a following buyers with applications exists:" do |buyers|
  buyers.hashes.each do |buyer|
    step %(a buyer "#{buyer['name']}" signed up to provider "#{buyer['provider']}")
    buyer['applications'].from_sentence.each do |application|
      step %(buyer "#{buyer['name']}" has application "#{application}")
    end
  end
end

def check_or_uncheck_selected_row(set, text = nil)
  selector = if text
               content = text.inspect
               [:xpath, "//tbody/tr/td[*[text() = #{content}] | text() = #{content}]/preceding-sibling::td//input[@type='checkbox' and contains(@name,'select')]"]
             else
               "input[type='checkbox'][name*='select']"
             end

  all(*selector).each do |checkbox|
    checkbox.set(set)
  end
end

When "I {check} the first select in table body" do |check|
  within 'table.data tbody' do
    first("input[type='checkbox'][name*='select']").set(check)
  end
end

When "I {check} select for {strings}" do |check, names|
  names.each do |n|
    check_or_uncheck_selected_row check, n
  end
end

When "I {check} select in table header" do |check|
  within 'table.data thead' do
    check_or_uncheck_selected_row check
  end
end

Then "{word} selects should be checked" do |m|
  assert all('table.data tbody tr td.select input[type=checkbox]').send(m + '?', &:checked?)
end


And "close the colorbox" do
  find('#cboxClose').click
end
