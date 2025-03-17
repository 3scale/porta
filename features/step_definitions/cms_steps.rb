# frozen_string_literal: true

When(/^I follow "([^"]*)" from the CMS "([^"]*)" dropdown$/) do |link, dropdown_title|
  # the 'cms-sidebar:update' event that triggers the event handlers for the dropdown button depends on AJAX response
  wait_for_requests

  dropdown_title.match? /^New/
  context = if dropdown_title.match? /^New/
              find('#cms-new-content-button')
            else
              find('button.pf-c-dropdown__toggle-button:not(.dropdown-toggle)', text: dropdown_title).ancestor('.pf-c-dropdown')
            end
  within context do
    find('.dropdown-toggle').click unless has_css?('.pf-c-dropdown.pf-m-expanded', wait: 0)
    click_on link
  end
  # Publish and Save dropdown actions trigger AJAX requests
  wait_for_requests if %w[Publish Save].include?(link)
end

When "fill the template draft with {}" do |value|
  fill_in_codemirror('cms-template-draft', value)
end

And "save it as version" do
  find('button[value=Save]').sibling('.dropdown-toggle').click
  click_button('Save as Version')
end

# TODO: compbine this with features/support/helpers/api_docs_service_helper.rb
def fill_in_codemirror(id, value)
  page.execute_script "document.querySelector('##{id} .CodeMirror').CodeMirror.setValue(#{value.dump})"

  find('.pf-c-page').click # HACK: need to click outside to lose focus
end
