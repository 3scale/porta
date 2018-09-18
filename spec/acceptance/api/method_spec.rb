require 'spec_helper'

resource "Metric" do

  let(:service) { provider.services.default }
  let(:hits)    { service.metrics.hits }

  let(:service_id) { service.id }
  let(:metric_id) { service.metrics.hits.id }

  let(:resource) { Factory.build(:metric, service: service, parent: hits) }

  let(:resource_representer) { 'MethodRepresenter' }
  let(:collection_representer) { 'MethodsRepresenter' }

  api 'method' do
    get '/admin/api/services/:service_id/metrics/:metric_id/methods.:format', action: :index

    get '/admin/api/services/:service_id/metrics/:metric_id/methods/:id.:format', action: :show

    context do
      parameter :system_name, 'Method System Name'
      parameter :friendly_name, 'Method Friendly Name'

      post '/admin/api/services/:service_id/metrics/:metric_id/methods.:format', action: :create do
        let(:system_name) { 'method_name' }
        let(:friendly_name) { 'Friendly Method' }
      end

      # creating a method using deprecated api.
      post '/admin/api/services/:service_id/metrics/:metric_id/methods.:format', action: :create do
        let(:name) { 'pesetas' }
        let(:friendly_name) { 'Friendly Method' }
      end

      put '/admin/api/services/:service_id/metrics/:metric_id/methods/:id.:format', action: :update do
        let(:system_name) { 'other_name' }
        let(:friendly_name) { 'Less Friendly Method' }
      end
    end

    delete '/admin/api/services/:service_id/metrics/:metric_id/methods/:id', action: :destroy
  end

  json(:resource) do
    let(:root) { 'method' }
    it { should have_properties('id', 'name', 'system_name', 'friendly_name') }
    it { should_not include('unit')}
    it { should have_links('self', 'parent') }
  end

  json(:collection) do
    let(:root) { 'methods' }
    it { should be_an(Array) }
  end
end

__END__
                     admin_api_service_metric_methods GET    /admin/api/services/:service_id/metrics/:metric_id/methods(.:format)                                   admin/api/metric_methods#index {:format=>"xml"}
                                                      POST   /admin/api/services/:service_id/metrics/:metric_id/methods(.:format)                                   admin/api/metric_methods#create {:format=>"xml"}
                      admin_api_service_metric_method GET    /admin/api/services/:service_id/metrics/:metric_id/methods/:id(.:format)                               admin/api/metric_methods#show {:format=>"xml"}
                                                      PUT    /admin/api/services/:service_id/metrics/:metric_id/methods/:id(.:format)                               admin/api/metric_methods#update {:format=>"xml"}
                                                      DELETE /admin/api/services/:service_id/metrics/:metric_id/methods/:id(.:format)                               admin/api/metric_methods#destroy {:format=>"xml"}
