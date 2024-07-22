# frozen_string_literal: true

Given "they visit the developer portal in CMS mode" do
  visit access_code_url(host: @provider.external_domain,
                        cms: 'draft',
                        cms_token: @provider.settings.cms_token!,
                        access_code: @provider.site_access_code)
end

Given "the CMS toolbar has been previously hidden" do
  # FIXME: Unfortunately we can't stub just cookie['cms-toolbar-state'] without breaking the rest
  # ActionDispatch::Cookies::CookieJar.any_instance.stubs('[]').with('cms-toolbar-state').returns('hidden')
  ActionDispatch::Cookies::CookieJar.any_instance.stubs('[]').returns('hidden')
end

Then "there should not be a CMS toolbar" do
  assert_no_selector '#cms-toolbar'
end

Then "the cms toolbar {should} be visible" do |should|
  assert_selector('.pf-c-drawer #cms-toolbar')
  assert_equal should, find('.pf-c-drawer')[:class].include?('pf-m-expanded')
end
