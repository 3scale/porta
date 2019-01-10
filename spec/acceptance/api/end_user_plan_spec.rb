require 'rails_helper'

resource "EndUserPlan" do

  let(:service) { provider.services.default }
  let(:resource) { FactoryBot.build(:end_user_plan, issuer: service) }
  let(:plan) { resource }

  let(:service_id) { service.id }

  before do
    provider.settings.allow_end_users!
  end

  api 'end user plan' do
    get "/admin/api/services/:service_id/end_user_plans.:format", action: :index

    get "/admin/api/services/:service_id/end_user_plans/:id.:format", action: :show

    context do
      parameter :name, 'End User Plan Name'
      let(:name) { 'Example Plan' }

      post "/admin/api/services/:service_id/end_user_plans.:format", action: :create
      put "/admin/api/services/:service_id/end_user_plans/:id.:format", action: :update
    end

    put "/admin/api/services/:service_id/end_user_plans/:id/default.:format", action: :default do
      let(:default) { service.reload.default_end_user_plan }
    end
  end

  json(:resource) do
    let(:root) { 'end_user_plan' }
    it { should have_properties('id', 'name', 'default').from(resource) }
    it { should have_links('service', 'self') }
  end

  json(:collection) do
    let(:root) { 'end_user_plans' }
    it { should be_an(Array) }
  end
end

__END__

              default_admin_api_service_end_user_plan PUT    /admin/api/services/:service_id/end_user_plans/:id/default(.:format)                                   admin/api/services/end_user_plans#default {:format=>"xml"}
                     admin_api_service_end_user_plans GET    /admin/api/services/:service_id/end_user_plans(.:format)                                               admin/api/services/end_user_plans#index {:format=>"xml"}
                                                      POST   /admin/api/services/:service_id/end_user_plans(.:format)                                               admin/api/services/end_user_plans#create {:format=>"xml"}
                      admin_api_service_end_user_plan GET    /admin/api/services/:service_id/end_user_plans/:id(.:format)                                           admin/api/services/end_user_plans#show {:format=>"xml"}
                                                      PUT    /admin/api/services/:service_id/end_user_plans/:id(.:format)                                           admin/api/services/end_user_plans#update {:format=>"xml"}
