# frozen_string_literal: true

require 'rails_helper'

resource 'OIDCConfiguration' do
  let(:proxy) { provider.default_service.proxy }
  let(:resource) { FactoryBot.create(:oidc_configuration, oidc_configurable: proxy) }

  json(:resource) do
    let(:root) { 'oidc_configuration' }
    it { subject.should have_properties(%w[id standard_flow_enabled implicit_flow_enabled service_accounts_enabled direct_access_grants_enabled]).from(resource) }

    let(:service_id){ resource.oidc_configurable.service_id }

    context  'set some flows to true' do
      parameter :service_accounts_enabled, 'Service Accounts Flow'
      parameter :implicit_flow_enabled, 'Implicit Flow'

      put "/admin/api/services/:service_id/proxy/oidc_configuration.json" do
        let(:service_accounts_enabled) { true }
        let(:implicit_flow_enabled) { true }

        request 'Update' do
          expect(status).to eq(200)
          updatable_resource.reload
          expect(updatable_resource.standard_flow_enabled).to eq(true)
          expect(updatable_resource.service_accounts_enabled).to eq(true)
          expect(updatable_resource.implicit_flow_enabled).to eq(true)
          expect(updatable_resource.direct_access_grants_enabled).to eq(false)
        end
      end
    end
  end
end
