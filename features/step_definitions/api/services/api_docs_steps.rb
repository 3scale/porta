# frozen_string_literal: true

Given "{provider} has a {spec_version} spec {string}" do |provider, version, name|
  @api_docs_service = FactoryBot.create(:api_docs_service, account: provider,
                                                           name: name,
                                                           body: spec_body_builder(version))
end

Given "{product} has a {spec_version} spec {string}" do |product, version, name|
  @api_docs_service = FactoryBot.create(:api_docs_service, account: product.provider,
                                                           name: name,
                                                           service: product,
                                                           published: true,
                                                           body: spec_body_builder(version))
end

Given "{api_docs_service} {is} published" do |spec, published|
  spec.update!(published: published)
end

Then "the swagger autocomplete should work for {string} with {string}" do |input_name, autocomplete|
  find('span', text: /get/i).click
  has_css?(".apidocs-param-tips.#{autocomplete}", visible: :hidden)
  find("input[name=#{input_name}]").click
  assert_selector(:css, ".apidocs-param-tips.#{autocomplete}", visible: :visible)
end

Then "{spec_version} should escape properly the curl string" do |swagger_version|
  find('span', text: /get/i).click
  assert find(:xpath, '//*[@name="user_key"]/..').has_sibling? 'td', text: 'header'
  page.fill_in 'user_key', with: 'Authorization: Oauth:"test"'
  page.click_button 'Try it out!'
  curl_commmand = find_all('div', text: /curl/i).last
  assert curl_commmand.has_text?(swagger_version == '1.2' ? 'Authorization: Oauth:\"test\"' : 'Authorization: Oauth:"test"')
end

When "the ActiveDocs form is submitted with:" do |table|
  if (api_json_spec = table.rows_hash.delete('API JSON Spec'))
    version = numbered_swagger_version(api_json_spec)
    fill_in_api_docs_service_body(spec_body_builder(version))
  end
  submit_form_with(table)
  @api_docs_service = ApiDocs::Service.last
end
