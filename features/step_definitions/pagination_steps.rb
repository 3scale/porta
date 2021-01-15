# frozen_string_literal: true

Then "I should see {amount} page(s)" do |count|
  links = within ".pagination" do
    all("a:not(.next_page), em.current")
  end
  assert links.present?, "No pagination found"
  assert_equal count.to_s, links.last.text
end

When "I look at {int}st/nd/rd/th page" do |page|
  within ".pagination" do
    click_link page
  end
end
