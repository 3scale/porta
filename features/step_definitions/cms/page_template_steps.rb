When /^I fill in (?:the )?draft with:$/ do |text|
  fill_draft(text)
end

When /^I fill in the draft with "([^"]*)"$/ do |text|
  fill_draft(text)
end

def fill_draft(text)
  if @javascript
    wait_for_requests
    page.execute_script <<-JS
      $('#cms_template_draft').data('codemirror').setValue(#{text.inspect});
    JS
  else
    raise 'Please mark this scenario with @javascript if you want to work with codemirror.'
  end
end

Given /^the template "([^"]*)" of (provider "[^"]*") is$/ do |name, provider, html|
  #TODO: extract PageTemplate construction to FactoryBot or whatever factory
  if layout = provider.layouts.find_by_system_name(name)
    layout.update_attribute(:body, html)
  else
    provider.layouts.create!(:system_name => name){ |l| l.body = html }
  end
end
