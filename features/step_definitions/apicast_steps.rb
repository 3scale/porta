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

Given(/^apicast registry is undefined$/) do
  ThreeScale.config.sandbox_proxy.stubs(:apicast_registry_url).returns(nil)
  ThreeScale.config.sandbox_proxy.stubs(:self_managed_apicast_registry_url).returns(nil)
  JSONClient.expects(:get).with(nil).raises(SocketError)
end

Given(/^I toggle the apicast version$/) do
  proxy = @provider.default_service.proxy
  proxy.toggle!(:apicast_configuration_driven) if !proxy.oidc? || !proxy.apicast_configuration_driven # rubocop:disable Rails/SkipsModelValidations
end
