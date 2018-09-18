
Factory.define (:proxy) do |factory|
  factory.association :service
  factory.api_backend 'http://api.example.net:80'
  factory.secret_token "123"
  factory.policies_config([{name: 'cors', version: '0.0.1', configuration: {foo: 'bar'}}])
end

Factory.define (:proxy_log) do |factory|
  factory.association(:provider, :factory => :provider_account)
  factory.lua_file "bla bla"
  factory.status 'Deployed successfully.' # other option: 'Deploy failed.'
end

Factory.define(:proxy_rule) do |factory|
  factory.http_method "GET"
  factory.pattern '/foo/bar'
  factory.delta 1
  factory.association :metric
  factory.association :proxy
end

Factory.define(:proxy_config) do |factory|
  factory.content ({ proxy: { hosts: ['example.com']}}.to_json)
  factory.environment 'sandbox'
  factory.association :proxy
end
