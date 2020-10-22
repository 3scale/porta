# frozen_string_literal: true

Given "I have changed CMS page {string}" do |name|
  assert @provider
  page = FactoryBot.create(:cms_page, system_name: name, provider: @provider)
  page.draft = "some draft content"
  page.save!
end

Given "I have changed CMS partial {string}" do |name|
  assert @provider
  page = FactoryBot.create(:cms_partial, system_name: name, provider: @provider)
  page.draft = "some draft content"
  page.save!
end

def cms_changes
  find("#cms-changes tbody")
end

Then "I should see {int} CMS changes" do |count|
  cms_changes.should have_css("tr", count: count)
end

Then "the CMS page {string} should be reverted" do |name|
  wait_for_requests
  page = CMS::Page.find_by!(system_name: name)
  page.draft.should be_nil
  cms_changes.should_not have_css("#cms_page_#{page.id}_change")
end

Given "there are no recent cms templates" do
  # FIXME: Avoid using `update_all` because it skips validations.Rails/SkipsModelValidations
  CMS::Template.recents.update_all('created_at = updated_at')
end
