# frozen_string_literal: true

Given "{provider} has email template {string}" do |provider, system_name, content|
  FactoryBot.create(:cms_email_template, provider:, system_name:, published: content)
end

Then "I should see default content of email template {string}" do |name|
  t = CMS::EmailTemplate.dup.extend(CMS::EmailTemplate::ProviderAssociationExtension)

  content = t.find_default_by_name(name).published
  assert has_xpath?(XPath.descendant(:textarea)[XPath.text.is(content)], visible: :hidden)
end
