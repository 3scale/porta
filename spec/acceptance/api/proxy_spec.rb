require 'rails_helper'

resource 'Proxy' do
  let(:service) { provider.services.default }
  let(:resource) { service.proxy }

  let(:service_id) { service.id }

  before do
    service.build_default_backend_api_config.save!
  end

  api 'proxy' do
    get '/admin/api/services/:service_id/proxy.:format', action: :show

    put '/admin/api/services/:service_id/proxy.:format', action: :update do
      parameter :credentials_location, 'Credentials Location'
      parameter :api_backend, 'Private endpoint'

      let(:credentials_location) { 'headers' }
      let(:api_backend) { 'https://private.example.com:443' }

      request 'should change api_backend' do
        resource.reload
        resource.api_backend.should eq(api_backend)
      end
    end
  end

  json(:resource) do
    let(:root) { 'proxy' }
    it { should include('credentials_location' => resource.credentials_location) }
    it { should include('deployment_option' => resource.deployment_option.to_s) }
    it { should have_links('mapping_rules', 'service', 'self') }
    it { should include('api_backend' => resource.api_backend) }
  end
end

__END__
admin_api_service_proxy GET      /admin/api/services/:service_id/proxy(.:format)     admin/api/services/proxies#show {:format=>"xml"}
                        PATCH    /admin/api/services/:service_id/proxy(.:format)     admin/api/services/proxies#update {:format=>"xml"}
                        PUT      /admin/api/services/:service_id/proxy(.:format)     admin/api/services/proxies#update {:format=>"xml"}
