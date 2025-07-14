# frozen_string_literal: true

Given /^they visit the developer portal in CMS mode(\swith an expired signature)?/ do |token_is_expired|
  provider_id = @provider.id
  expires_at = Time.now.utc.round - 30.seconds
  expires_at += 1.minute unless token_is_expired
  signature = CMS::Signature.generate(provider_id, expires_at)

  visit access_code_url(host: @provider.external_domain,
                        cms: 'draft',
                        expires_at: expires_at.to_i,
                        signature:,
                        access_code: @provider.site_access_code)
end

Given /^they visit the developer portal home page/ do
  visit root_url(host: @provider.external_domain)
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
  drawer = find('.pf-c-drawer')
  assert_equal should, drawer.has_selector?('#cms-toolbar', wait: 0)
  assert_equal should, drawer[:class].include?('pf-m-expanded')
end
