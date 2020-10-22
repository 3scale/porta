# frozen_string_literal: true

Then "the content of the {email_template} should be" do |template, string|
  assert_equal string, template.content
end

Then "the headers of {email_template} should be following:" do |template, table|
  headers = template.headers.to_hash
  headers = [headers.keys.map(&:to_s), headers.values]

  table.diff! headers
end

Given "{provider} has email template {string}" do |provider, content|
  # Given /^(provider ".*?") has email template "(.*?)"$/ do |provider, system_name, content|
  provider.email_templates.create(published: content, system_name: provider.system_name)
end

Given "I have following email (templates) of {provider}:" do |provider, table|
  table.map_headers! {|header| header.parameterize.underscore.downcase.to_s }
  table.hashes.each do |attrs|
    attrs[:provider] = provider
    attrs[:updated_at] = Time.zone.now
    FactoryBot.create(:cms_email_template, attrs).save!
  end
end

Then "I should see default content of email template {string}" do |name|
  t = CMS::EmailTemplate.dup.extend(CMS::EmailTemplate::ProviderAssociationExtension)

  content = t.find_default_by_name(name).published
  page.find :xpath, XPath.descendant(:textarea)[XPath.text.is(content)], visible: :hidden
end
