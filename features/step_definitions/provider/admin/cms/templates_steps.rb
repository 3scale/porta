# frozen_string_literal: true

Given /^a dev portal (page|partial) "([^"]*)"$/ do |type, title|
  FactoryBot.create("cms_#{type}", provider: @provider,
                                   title:,
                                   body: 'foo')
end

Given "a dev portal layout {string}" do |title|
  FactoryBot.create(:cms_layout, provider: @provider,
                                 title:,
                                 body: '{% content %}')
end

Given "{provider} has a partial {string} with the following content:" do |provider, system_name, body|
  FactoryBot.create(:cms_partial, system_name:, provider:, body:)
end

Given "{provider} has the following page(s):" do |provider, table|
  transform_cms_pages_table(table, provider:)
  table.hashes.each do |options|
    title = options[:title]
    unless options[:path]
      path = title.parameterize
      options[:path] = if (section = options[:section])
                         "#{section.full_path}/#{path}"
                       else
                         path
                       end
    end

    FactoryBot.create(:cms_page, provider:,
                                 system_name: options[:system_name] || title.parameterize,
                                 **options)
  end
end


Given "a dev portal {word} {string} has unpublished changes" do |type, title|
  FactoryBot.create("cms_#{type}", provider: @provider,
                                   title:,
                                   path: "/#{title.parameterize}",
                                   published: 'Old',
                                   draft: 'New')
end

Given "the template of dev portal's {string} of {provider} is" do |system_name, provider, html|
  provider.templates.find_by!(system_name:)
                    .update_attribute(:body, html) # rubocop:disable Rails/SkipsModelValidations
end

When "(they )fill the template draft with {}" do |value|
  fill_in_codemirror('cms-template-draft', value)
end

When "unpublish the template" do
  cms_buttons_click('publish', 'Hide')
end

When "save it as version" do
  cms_buttons_click('save', 'Save as Version')
end

When "(they )fill in the draft with:" do |text|
  fill_draft(text)
end

Then "the button Preview should link to {string}" do |path|
  popup = window_opened_by do
    find("#cms-preview-button").click_link_or_button("Preview")
  end

  page.within_window popup do
    assert_match path, current_path
  end
end

Then /^the (draft|published|version) template should contain "([^"]*)"?/ do |type, text|
  assert has_css?("textarea#cms_template_#{type}", visible: :hidden, text:, wait: 0)
end

def fill_draft(text)
  ensure_javascript

  find('#cms_template_draft', visible: :all)
  execute_script("$('#cms_template_draft').data('codemirror').setValue(#{text.inspect});")
end
