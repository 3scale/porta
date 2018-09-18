# frozen_string_literal: true

Given(/^apicast registry is stubbed$/) do
  stub_request(:get, 'http://apicast.alaska/policies')
    .with(headers: { 'Accept' => '*/*' })
    .to_return(status: 200, body: "{\"policies\":{\"apicast\":[{\"description\":\"Main functionality of APIcast.\",\"$schema\":\"http:\\/\\/apicast.io\\/policy-v1\\/schema#manifest#\",\"name\":\"APIcast policy\",\"configuration\":{\"properties\":{},\"type\":\"object\"},\"version\":\"builtin\"}]}}",
               headers: { 'Content-Type' => 'application/json' })
end
