require 'rails_helper'

resource 'Proxy' do
  let(:service) { provider.services.default }
  let(:resource) { service.proxy }

  let(:service_id) { service.id }

  api 'proxy' do
    get '/admin/api/services/:service_id/proxy.:format', action: :show

    put '/admin/api/services/:service_id/proxy.:format', action: :update do
      parameter :credentials_location, 'Credentials Location'

      let(:credentials_location) { 'headers' }
    end
  end

  json(:resource) do
    let(:root) { 'proxy' }
    it { should include('credentials_location' => resource.credentials_location) }
    it { should have_links('mapping_rules', 'service', 'self') }
  end
end

__END__
admin_api_service_proxy GET      /admin/api/services/:service_id/proxy(.:format)     admin/api/services/proxies#show {:format=>"xml"}
                        PATCH    /admin/api/services/:service_id/proxy(.:format)     admin/api/services/proxies#update {:format=>"xml"}
                        PUT      /admin/api/services/:service_id/proxy(.:format)     admin/api/services/proxies#update {:format=>"xml"}
