require 'rails_helper'

resource 'Proxy' do
  let(:service) { provider.services.default }
  let(:resource) { service.proxy }

  let(:service_id) { service.id }

  api 'proxy' do
    get '/admin/api/services/:service_id/proxy.:format', action: :show

    put '/admin/api/services/:service_id/proxy.:format', action: :update do
      parameter :credentials_location, 'Credentials Location'
      parameter :api_backend, 'Private endpoint'
      parameter :jwt_claim_with_client_id, 'JWT Claim with ClientID Location'
      parameter :jwt_claim_with_client_id_type, 'JWT Claim with ClientID Type'

      let(:credentials_location) { 'headers' }
      let(:api_backend) { 'https://private.example.com:443' }
      let(:jwt_claim_with_client_id) { 'azp' }
      let(:jwt_claim_with_client_id_type) { 'plain' }

      request 'should change api_backend' do
        resource.reload
        resource.api_backend.should eq(api_backend)
      end

      request 'should change jwt_claim_with_client_id_type' do
        resource.reload
        resource.jwt_claim_with_client_id_type.should eq(jwt_claim_with_client_id_type)
      end

      request 'should change jwt_claim_with_client_id' do
        resource.reload
        resource.jwt_claim_with_client_id.should eq(jwt_claim_with_client_id)
      end
    end
  end

  json(:resource) do
    let(:root) { 'proxy' }

    parameter :api_backend, 'Private endpoint'

    let(:api_backend) { 'https://private.example.com:443' }

    it { should include('credentials_location' => resource.credentials_location) }
    it { should include('deployment_option' => resource.deployment_option.to_s) }
    it { should have_links('mapping_rules', 'service', 'self') }
    it { should include('api_backend' => resource.api_backend) }

    context 'OIDC' do
      before do
        resource.update!(authentication_method: :oidc, jwt_claim_with_client_id_type: 'plain', jwt_claim_with_client_id: 'azp')
      end

      it { should include('jwt_claim_with_client_id' => 'azp') }
      it { should include('jwt_claim_with_client_id_type' => 'plain') }
    end
  end
end

__END__
admin_api_service_proxy GET      /admin/api/services/:service_id/proxy(.:format)     admin/api/services/proxies#show {:format=>"xml"}
                        PATCH    /admin/api/services/:service_id/proxy(.:format)     admin/api/services/proxies#update {:format=>"xml"}
                        PUT      /admin/api/services/:service_id/proxy(.:format)     admin/api/services/proxies#update {:format=>"xml"}
