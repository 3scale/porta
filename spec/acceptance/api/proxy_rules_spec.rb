require 'rails_helper'

resource 'ProxyRule' do

  let(:service) { provider.services.default }
  let(:proxy) { service.proxy }
  let(:metric) { service.metrics.hits }

  let(:resource) { FactoryBot.build(:proxy_rule, proxy: proxy, metric: metric) }
  let(:collection) { proxy.proxy_rules.order(:id) }

  let(:service_id) { service.id }

  api 'mapping rules' do
    get '/admin/api/services/:service_id/proxy/mapping_rules.:format', action: :index
    get '/admin/api/services/:service_id/proxy/mapping_rules/:id.:format', action: :show
    delete '/admin/api/services/:service_id/proxy/mapping_rules/:id.:format', action: :destroy

    context do
      parameter :metric_id, 'Metric ID'
      let(:metric_id) { metric.id } # TODO: create & use different metric
      parameter :delta, 'Delta'
      let(:delta) { 2 }
      parameter :http_method, 'HTTP Method', method: :http_verb
      let(:http_verb) { 'PATCH' }
      parameter :pattern, 'Pattern'
      let(:pattern) { '/foo' }

      post '/admin/api/services/:service_id/proxy/mapping_rules.:format', action: :create
      put '/admin/api/services/:service_id/proxy/mapping_rules/:id.:format', action: :update
    end
  end

  json(:resource) do
    let(:root) { 'mapping_rule' }
    it { should include('metric_id' => resource.metric_id) }
    it { should include('pattern' => resource.pattern) }
    it { should include('http_method' => resource.http_method) }
    it { should include('delta' => resource.delta) }
    it { should have_links('proxy', 'service', 'self') }
  end

  json(:collection) do
    let(:root) { 'mapping_rules' }
    it { should be_an(Array) }
  end
end

__END__
                admin_api_service_proxy_mapping_rules GET      /admin/api/services/:service_id/proxy/mapping_rules(.:format)                                    admin/api/services/mapping_rules#index {:format=>"xml"}
                                                      POST     /admin/api/services/:service_id/proxy/mapping_rules(.:format)                                    admin/api/services/mapping_rules#create {:format=>"xml"}
                 admin_api_service_proxy_mapping_rule GET      /admin/api/services/:service_id/proxy/mapping_rules/:id(.:format)                                admin/api/services/mapping_rules#show {:format=>"xml"}
                                                      PATCH    /admin/api/services/:service_id/proxy/mapping_rules/:id(.:format)                                admin/api/services/mapping_rules#update {:format=>"xml"}
                                                      PUT      /admin/api/services/:service_id/proxy/mapping_rules/:id(.:format)                                admin/api/services/mapping_rules#update {:format=>"xml"}
                                                      DELETE   /admin/api/services/:service_id/proxy/mapping_rules/:id(.:format)                                admin/api/services/mapping_rules#destroy {:format=>"xml"}
