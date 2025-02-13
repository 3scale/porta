# frozen_string_literal: true

When(/^I follow "([^"]*)" from the CMS dropdown$/) do |link|
  within '#cms-new-content-button' do
    find('.dropdown-toggle').click unless has_css?('ul.dropdown.expanded')
    click_on link
  end
end

When "fill the template draft with {}" do |value|
  fill_in_codemirror('cms-template-draft', value)
end

And "save it as version" do
  find('input[value=Save]').sibling('.dropdown-toggle').click
  click_button('Save as Version')
end

# TODO: compbine this with features/support/helpers/api_docs_service_helper.rb
def fill_in_codemirror(id, value)
  page.execute_script "document.querySelector('##{id} .CodeMirror').CodeMirror.setValue(#{value.dump})"

  find('.pf-c-page').click # HACK: need to click outside to lose focus
end
