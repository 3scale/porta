
Then /^I should see (\d+) pages$/ do |count|
  links = within(".pagination") do
    all("a:not(.next_page), em.current")
  end
  assert links.present?, "No pagination found"
  assert_equal count.to_s, links.last.text
end

When /^I look at (\d+)(?:st|rn|nd|th) page$/ do |page|
  within ".pagination" do
    click_link page
  end
end
