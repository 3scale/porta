# frozen_string_literal: true

Given "{provider} has email template {string}" do |provider, system_name, content = nil|
  attrs = {}

  attrs[:published] = content if content.present?

  FactoryBot.create(:cms_email_template, provider:, system_name:, **attrs)
end

Then /^I should see default content of email template "(.+?)"$/ do |name|
  t = CMS::EmailTemplate.dup.extend(CMS::EmailTemplate::ProviderAssociationExtension)

  text = t.find_default_by_name(name).published
  has_css?("textarea#cms_template_draft", visible: :hidden, text:, wait: 0)
end
