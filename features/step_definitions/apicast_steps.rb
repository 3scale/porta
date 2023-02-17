# frozen_string_literal: true

Given(/^apicast registry is stubbed$/) do
  stub_request(:get, 'http://apicast.alaska/policies')
    .with(headers: { 'Accept' => '*/*' })
    .to_return(status: 200, body: "{\"policies\":{\"apicast\":[{\"description\":\"Main functionality of APIcast.\",\"$schema\":\"http:\\/\\/apicast.io\\/policy-v1\\/schema#manifest#\",\"name\":\"APIcast policy\",\"configuration\":{\"properties\":{},\"type\":\"object\"},\"version\":\"builtin\"}]}}",
               headers: { 'Content-Type' => 'application/json' })
  stub_request(:get, 'http://self-managed.apicast.alaska/policies')
    .with(headers: { 'Accept' => '*/*' })
    .to_return(status: 200, body: "{\"policies\":{\"apicast\":[{\"description\":\"Main functionality of APIcast.\",\"$schema\":\"http:\\/\\/apicast.io\\/policy-v1\\/schema#manifest#\",\"name\":\"APIcast policy\",\"configuration\":{\"properties\":{},\"type\":\"object\"},\"version\":\"builtin\"}]}}",
      headers: { 'Content-Type' => 'application/json' })
end

Given(/^the default proxy does not use apicast configuration driven$/) do
  proxy = @provider.default_service.proxy
  proxy.update!(apicast_configuration_driven: false, sandbox_endpoint: 'https://api-2.staging.apicast.io:4443')
end
