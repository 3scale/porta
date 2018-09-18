Then(/^the swagger autocomplete should work for "(.*?)" with "(.*?)"$/) do |input_name, autocomplete|
  click_on 'get'
  assert_equal 1, evaluate_script("$('input[name=#{input_name}]').focus().length")
  assert_equal 1, evaluate_script("$('.apidocs-param-tips.#{autocomplete}:visible').length")
end

Then 'I fill in the API JSON Spec with:' do |spec|
  selector = 'textarea#api_docs_service_body ~ .CodeMirror'

  find(:css, selector)

  page.evaluate_script <<-JS
    document.querySelector(#{selector.to_json}).CodeMirror.setValue(#{spec.to_json})
  JS
end
