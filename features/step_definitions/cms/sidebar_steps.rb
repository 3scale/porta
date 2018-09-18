When /^(.*) in the CMS sidebar$/ do |step|
  within "#cms-sidebar" do
    step(step)
  end
end


When /^I switch to (builtin|3scale) content$/ do |group|
  ensure_javascript

  within "#cms-sidebar-filter-origin" do
    li = page.find("li[data-filter-origin='builtin']")
    li.click
  end
end


When /^I choose builtin page "(.*?)"$/ do |system_name|
  css = "#cms-sidebar li[data-search=\"#{system_name}\"] a"
  link = page.document.find(css)
  link.click
end
