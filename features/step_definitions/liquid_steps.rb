Given /^the provider has cms page "(.*?)" with:$/ do |path, content|
  FactoryBot.create(:cms_page, provider: @provider, path: path, published: content, liquid_enabled: true)
end

Given /^I visit a page showing the current user's SSO data$/ do
  steps <<-GHERKIN
    Then I should be logged in the Developer Portal
    Given the provider has cms page "/sso_authorizations" with:
      """
      {% for authorization in current_user.sso_authorizations %}
        <p><strong>{{ authorization.authentication_provider_system_name }}</strong>: {{ authorization.id_token }}</p>
      {% endfor %}
      """
    And I visit "/sso_authorizations"
  GHERKIN
end

Given /^I'm logged in as a malicious buyer$/ do
  step "the current domain is #{@provider.domain}"
  step %|a buyer "malicious_buyer" of provider "#{@provider.org_name}"|
  Account.buyers.last!.update_attribute(:org_name, 'malicious <script></script>buyer')
  step 'I am logged in as "malicious_buyer"'
end

When /^provider has xss protection enabled$/ do
  @provider.settings.update_attributes(cms_escape_draft_html: true,
                                       cms_escape_published_html: true)
end

When /^provider has xss protection disabled$/ do
  @provider.settings.update_attributes(cms_escape_draft_html: false,
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
  step "the html body should contain \"#{authorization.authentication_provider.system_name}\""
  step "the html body should contain \"#{authorization.id_token}\""
end
