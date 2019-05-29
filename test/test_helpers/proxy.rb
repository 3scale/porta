def stub_apicast_registry
  url = 'http://apicast.alaska/policies'
  stubbed_registry = { policies: { apicast: [JSON.parse(file_fixture('policies/apicast-policy.json').read)] } }.to_json
  ThreeScale.config.sandbox_proxy.stubs(apicast_registry_url: url)

  stub_request(:get, url)
      .with(headers: { 'Accept' => '*/*' })
      .to_return(status: 200, body: stubbed_registry,
                 headers: { 'Content-Type' => 'application/json' })
end
