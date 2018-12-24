require 'spec_helper'

resource "ProxyConfig" do

  let(:service)     do
    service = provider.services.default
    service.service_tokens.create(value: 'token')
    service
  end
  let(:service_id)  { service.id }
  let(:resource)    { FactoryBot.create(:proxy_config, proxy: service.proxy) }
  let(:environment) { resource.environment }
  let(:version)     { resource.version }

  api 'proxy config', format: [:json] do
    get '/admin/api/services/:service_id/proxy/configs/:environment/latest.json',  action: :latest
    get '/admin/api/services/:service_id/proxy/configs/:environment/:version.json', action: :show
    get '/admin/api/services/:service_id/proxy/configs/:environment.json',         action: :index
    get '/admin/api/services/proxy/configs/:environment.json',                     action: :index_by_host
    post '/admin/api/services/:service_id/proxy/configs/:environment/:version/promote', action: :promote
  end

  json(:resource) do
    let(:root) { 'proxy_config' }
    it { should include('id' => resource.id) }
    it { should include('version'     => resource.version) }
    it { should include('environment' => resource.environment) }
    it { should include('content'     => JSON.parse(resource.content)) }
  end

  json(:collection) do
    let(:root) { 'proxy_configs' }
    it { should be_an(Array) }
  end
end

__END__
latest_admin_api_service_proxy_configs GET      /admin/api/services/:service_id/proxy/configs/:environment/latest(.:format) admin/api/services/proxy/configs#latest {:format=>"xml"}
promote_admin_api_service_proxy_config POST     /admin/api/services/:service_id/proxy/configs/:environment/:version/promote(.:format) admin/api/services/proxy/configs#promote {:format=>"xml"}
admin_api_service_proxy_configs GET      /admin/api/services/:service_id/proxy/configs/:environment(.:format) admin/api/services/proxy/configs#index {:format=>"xml"}
admin_api_service_proxy_config GET      /admin/api/services/:service_id/proxy/configs/:environment/:version(.:format) admin/api/services/proxy/configs#show {:format=>"xml"}
admin_api_proxy_configs GET      /admin/api/services/proxy/configs/:environment(.:format) admin/api/services/proxy/configs#index_by_host {:format=>"xml"}
