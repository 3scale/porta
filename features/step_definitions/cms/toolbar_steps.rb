Given /^I am in CMS Admin mode$/ do
  visit "/?cms_token=#{@provider.settings.cms_token!}"
end

Then /^I should see CMS Toolbar$/ do
  should have_css('#cms-toolbar')
end