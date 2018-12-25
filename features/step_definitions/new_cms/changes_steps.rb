Given /^I have changed CMS page "(.*?)"$/ do |name|
  assert @provider
  page = FactoryBot.create(:cms_page, :system_name => name, :provider => @provider)
  page.draft = "some draft content"
  page.save!
end

Given /^I have changed CMS partial "(.*?)"$/ do |name|
  assert @provider
  page = FactoryBot.create(:cms_partial, :system_name => name, :provider => @provider)
  page.draft = "some draft content"
  page.save!
end

def cms_changes
  find("#cms-changes tbody")
end

Then /^I should see (\d+) CMS changes$/ do |count|
  cms_changes.should have_css("tr", count: count)
end

Then /^the CMS page "(.*?)" should be reverted$/ do |name|
  page = CMS::Page.find_by_system_name!(name)
  page.draft.should be_nil
  cms_changes.should_not have_css("#cms_page_#{page.id}_change")
end


Given(/^there are no recent cms templates$/) do
  CMS::Template.recents.update_all('created_at = updated_at')
end
