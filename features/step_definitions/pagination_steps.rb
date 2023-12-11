# frozen_string_literal: true

Then /^I should see (\d+) pages$/ do |count|
  if has_css?('.pagination', wait: 0)
    # DEPRECATED! Implement table toolbar instead
    links = within(".pagination") do
      all("a:not(.next_page), em.current")
    end
    assert links.present?, "No pagination found"
    assert_equal count.to_s, links.last.text
  else
    within '.pf-c-pagination__nav-page-select' do
      assert_text "of #{count}"
    end
  end
end

When "they look at the {ordinal} page" do |page|
  if has_css?('.pagination', wait: 0)
    # DEPRECATED! Implement table toolbar instead
    within ".pagination" do
      click_link page
    end
  else
    input = find('input[aria-label="Current page"]')
    input.set(page)
    input.native.send_keys(:return)
  end
end
