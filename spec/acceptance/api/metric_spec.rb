require 'rails_helper'

resource "Metric" do

  let(:service) { provider.services.default }
  let(:resource) { FactoryBot.build(:metric, service: service) }

  let(:service_id) { service.id }

  api 'metric' do
    get '/admin/api/services/:service_id/metrics.:format', action: :index do
      let(:serializable) { [ service.metrics.hits, resource ]}
    end

    get '/admin/api/services/:service_id/metrics/:id.:format', action: :show

    context do
      parameter :system_name, 'Metric System Name'
      parameter :friendly_name, 'Metric Friendly Name'
      parameter :unit, 'Unit'

      post '/admin/api/services/:service_id/metrics.:format', action: :create do
        let(:system_name) { 'metric_name' }
        let(:friendly_name) { 'Friendly Metric' }
        let(:unit) { 'friend' }
      end

      put '/admin/api/services/:service_id/metrics/:id.:format', action: :update do
        let(:system_name) { 'other_name' }
        let(:friendly_name) { 'Less Friendly Metric' }
        let(:unit) { 'diff' }

        request 'updates name' do
          resource.reload
          resource.system_name.should eq(system_name)
        end
      end
    end

    delete '/admin/api/services/:service_id/metrics/:id', action: :destroy
  end

  json(:resource) do
    let(:root) { 'metric' }

    it { should have_properties('id', 'name', 'system_name', 'friendly_name', 'unit') }
    it { should have_links('service', 'self') }
    it { should_not have_links('parent') }
  end

  json(:collection) do
    let(:root) { 'metrics' }
    it { should be_an(Array) }
  end
end

__END__

admin_api_service_metrics GET    /admin/api/services/:service_id/metrics(.:format)      admin/api/metrics#index {:format=>"xml"}
                          POST   /admin/api/services/:service_id/metrics(.:format)      admin/api/metrics#create {:format=>"xml"}
 admin_api_service_metric GET    /admin/api/services/:service_id/metrics/:id(.:format)  admin/api/metrics#show {:format=>"xml"}
                          PUT    /admin/api/services/:service_id/metrics/:id(.:format)  admin/api/metrics#update {:format=>"xml"}
                          DELETE /admin/api/services/:service_id/metrics/:id(.:format)  admin/api/metrics#destroy {:format=>"xml"}
