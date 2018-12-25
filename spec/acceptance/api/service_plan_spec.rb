require 'spec_helper'

resource "ServicePlan" do

  let(:service) { provider.services.default }
  let(:resource) { FactoryBot.build(:service_plan, issuer: service) }

  let(:service_id) { service.id }

  api 'service plan' do
    get "/admin/api/services/:service_id/service_plans.:format", action: :index do
      let(:serializable) { [service.service_plans.first, resource ]}
    end

    get "/admin/api/services/:service_id/service_plans/:id.:format", action: :show

    post "/admin/api/services/:service_id/service_plans.:format", action: :create do
      parameter :name, 'Service Plan Name'
      let(:name) { 'Example Plan' }
    end

    put "/admin/api/services/:service_id/service_plans/:id.:format", action: :update do
      parameter :name, 'Service Plan Name'
      let(:name) { 'New Name' }
    end

    put "/admin/api/services/:service_id/service_plans/:id/default.:format", action: :default do
      let(:default) { service.reload.default_service_plan }
    end

    delete "/admin/api/services/:service_id/service_plans/:id", action: :destroy
  end

  api 'buyer service plans' do
    let(:account) { FactoryBot.create(:buyer_account, provider_account: provider) }
    let(:account_id) { account.id }

    get '/admin/api/accounts/:account_id/service_plans.:format', action: :index do
      before { account.buy!(resource) }

      let(:collection) { account.bought_service_plans }

      after { collection.should include(resource) }
    end

    post '/admin/api/accounts/:account_id/service_plans/:id/buy.:format', :resource do
      before { resource.save! }
      before { account.reload.bought_service_plans.should_not include(resource) }

      parameter :id, "Service Plan ID"
      let(:id) { resource.id }

      request "Buy #{model}", status: 201 do
        resource.should_not be_published
        account.reload.bought_service_plans.should include(resource)
      end
    end
  end

  json(:resource) do
    let(:root) { 'service_plan' }
    it { should have_properties('id', 'name', 'state', 'approval_required').from(resource) }
    it { should have_properties(%w|setup_fee cost_per_month trial_period_days cancellation_period|).from(resource) }
    it { should have_links('service', 'self') }
  end

  json(:collection) do
    let(:root) { 'plans' }
    it { should be_an(Array) }
  end
end

__END__

default_admin_api_service_service_plan PUT    /admin/api/services/:service_id/service_plans/:id/default(.:format) admin/api/service_plans#default {:format=>"xml"}
       admin_api_service_service_plans GET    /admin/api/services/:service_id/service_plans(.:format)             admin/api/service_plans#index {:format=>"xml"}
                                       POST   /admin/api/services/:service_id/service_plans(.:format)             admin/api/service_plans#create {:format=>"xml"}
        admin_api_service_service_plan GET    /admin/api/services/:service_id/service_plans/:id(.:format)         admin/api/service_plans#show {:format=>"xml"}
                                       PUT    /admin/api/services/:service_id/service_plans/:id(.:format)         admin/api/service_plans#update {:format=>"xml"}
                                       DELETE /admin/api/services/:service_id/service_plans/:id(.:format)         admin/api/service_plans#destroy {:format=>"xml"}

    buy_admin_api_account_service_plan POST   /admin/api/accounts/:account_id/service_plans/:id/buy(.:format)     admin/api/buyers_service_plans#buy {:format=>"xml"}
       admin_api_account_service_plans GET    /admin/api/accounts/:account_id/service_plans(.:format)             admin/api/buyers_service_plans#index {:format=>"xml"}
