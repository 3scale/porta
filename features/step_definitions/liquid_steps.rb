Given /^the provider has cms page "(.*?)" with:$/ do |path, content|
  FactoryBot.create(:cms_page, provider: @provider, path: path, published: content, liquid_enabled: true)
end

Given /^I visit a page showing the current user's SSO data$/ do
  assert_current_user 'foo'
  assert_current_path '/'

  content = '{% for authorization in current_user.sso_authorizations %}\n
               <p><strong>{{ authorization.authentication_provider_system_name }}</strong>: {{ authorization.id_token }}</p>\n
             {% endfor %}'
  FactoryBot.create(:cms_page, provider: @provider,
                               path: '/sso_authorizations',
                               published: content,
                               liquid_enabled: true)
  visit '/sso_authorizations'
end

Given /^I'm logged in as a malicious buyer$/ do
  buyer_name = "malicious_buyer"
  set_current_domain @provider.external_domain
  @account = FactoryBot.create(:buyer_account, provider_account: @provider, org_name: buyer_name)
  @account.buy!(@provider.account_plans.default)
  @account.update_attribute(:org_name, 'malicious <script></script>buyer')
  try_buyer_login_internal(buyer_name, 'superSecret1234#')
end

When /^provider has xss protection enabled$/ do
  @provider.settings.update(cms_escape_draft_html: true,
                                       cms_escape_published_html: true)
end

When /^provider has xss protection disabled$/ do
  @provider.settings.update(cms_escape_draft_html: false,
                                       cms_escape_published_html: false)
end

def main_layout
  @provider.layouts.find_by_system_name!('main_layout')
end

Given /^the cms page "(.*?)" has main layout$/ do |path|
  page = @provider.pages.find_by_path!(path)
  page.update_attribute(:layout, main_layout)
end

Given /^the provider has main layout with:$/ do |string|
  main_layout.update_attribute(:published, string)
end

Then /^the html body should contain "(.*?)"$/ do |html|
  page.find('body').native.to_s.should match(html)
end

Then /^the html head should contain "(.*?)"$/ do |html|
  page.find('head', visible: :all).native.to_s.should match(html)
end

Then /^the html should contain the SSO data$/ do
  authorization = User.find_by(email: 'foo@3scale.localhost').sso_authorizations.last!
  page.find('body').native.to_s.should match(authorization.authentication_provider.system_name)
  page.find('body').native.to_s.should match(authorization.id_token)
end
