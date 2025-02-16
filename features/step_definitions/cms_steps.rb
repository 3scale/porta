# frozen_string_literal: true

When(/^I follow "([^"]*)" from the CMS dropdown$/) do |link|
  # the 'cms-sidebar:update' event that triggers the event handlers for the dropdown button depends on AJAX response
  wait_for_requests
  within '#cms-new-content-button' do
    find('.dropdown-toggle').click
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
