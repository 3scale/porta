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
        let(:friendly_name) { 'Less Friendly Metric' }
        let(:unit) { 'diff' }

        request 'updates name' do
          resource.reload
          resource.friendly_name.should eq(friendly_name)
          resource.unit.should eq(unit)
        end
      end
    end

    delete '/admin/api/services/:service_id/metrics/:id', action: :destroy
  end

  api 'method_metric' do
    let(:resource) { FactoryBot.build(:metric, parent: service.metrics.hits) }

    get '/admin/api/services/:service_id/metrics/:id.:format', action: :show

    json(:resource) do
      let(:root) { 'metric' }

      it { should have_properties('id', 'name', 'system_name', 'friendly_name', 'parent_id').from(resource) }
    end
  end

  json(:resource) do
    let(:root) { 'metric' }

    it { should have_properties('id', 'name', 'system_name', 'friendly_name', 'unit').from(resource) }
    it { should_not have_properties('parent_id') }
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
