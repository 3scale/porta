require 'spec_helper'

resource "ApplicationPlan" do

  let(:service) { provider.services.default }
  let(:resource) { Factory.build(:application_plan, issuer: service) }

  let(:service_id) { service.id }

  api 'application plan' do
    get "/admin/api/services/:service_id/application_plans.:format", action: :index

    get "/admin/api/services/:service_id/application_plans/:id.:format", action: :show

    post "/admin/api/services/:service_id/application_plans.:format", action: :create do
      parameter :name, 'Application Plan Name'
      let(:name) { 'Example Plan' }
    end

    put "/admin/api/services/:service_id/application_plans/:id.:format", action: :update do
      parameter :name, 'Application Plan Name'
      let(:name) { 'New Name' }
    end

    put "/admin/api/services/:service_id/application_plans/:id/default.:format", action: :default do
      let(:default) { service.reload.default_application_plan }
    end

    delete "/admin/api/services/:service_id/application_plans/:id", action: :destroy
  end

  api 'buyer application plans' do
    let(:account) { Factory(:buyer_account, provider_account: provider) }
    let(:account_id) { account.id }

    get '/admin/api/accounts/:account_id/application_plans.:format', action: :index do
      before { account.buy!(resource) }

      let(:collection) { account.bought_application_plans }

      after { collection.should include(resource) }
    end

    post '/admin/api/accounts/:account_id/application_plans/:id/buy.:format', :resource do
      before { resource.save! }
      before { account.reload.bought_application_plans.should_not include(resource) }

      parameter :id, "Application Plan ID"
      let(:id) { resource.id }

      request "Buy #{model}", status: 201 do
        resource.should_not be_published
        account.reload.bought_application_plans.should include(resource)
      end
    end
  end

  json(:resource) do
    let(:root) { 'application_plan' }
    it do
      should have_properties(%w|id name state system_name|).from(resource)
      should have_properties(%w|setup_fee cost_per_month|).from(resource)
      should have_properties(%w|end_user_required trial_period_days cancellation_period|).from(resource)
      should have_links('self', 'service')
    end
  end

  json(:collection) do
    let(:root) { 'plans' }
    it { should be_an(Array) }
  end
end

__END__

                 admin_api_service_application_plans GET    /admin/api/services/:service_id/application_plans(.:format)                                            admin/api/application_plans#index {:format=>"xml"}
                                                     POST   /admin/api/services/:service_id/application_plans(.:format)                                            admin/api/application_plans#create {:format=>"xml"}
                  admin_api_service_application_plan GET    /admin/api/services/:service_id/application_plans/:id(.:format)                                        admin/api/application_plans#show {:format=>"xml"}
                                                     PUT    /admin/api/services/:service_id/application_plans/:id(.:format)                                        admin/api/application_plans#update {:format=>"xml"}
                                                     DELETE /admin/api/services/:service_id/application_plans/:id(.:format)                                        admin/api/application_plans#destroy {:format=>"xml"}
