require 'spec_helper'

resource "Feature" do

  let(:service) { provider.services.default }

  let(:plan_id) { plan.id }

  let(:feature) { FactoryBot.create(:feature, featurable: featurable, scope: scope) }
  let(:resource) { feature }
  let(:scope) { nil }

  shared_examples "feature plan" do
    before { FeaturesPlan.create!(feature: feature, plan: plan) }
  end

  shared_examples "feature" do
    parameter :name, "Feature Name"
    let(:name) { 'Some Feature Name' }
  end

  shared_context "feature params" do
    before { resource.save! }
    parameter :feature_id, 'Feature ID'
    let(:feature_id) { resource.id }
  end

  api 'account plan features' do
    let(:featurable) { provider }
    let(:scope) { 'AccountPlan' }
    let(:plan) { FactoryBot.create(:account_plan, issuer: provider) }

    post  '/admin/api/account_plans/:plan_id/features.:format', action: :create do
      include_context "feature params"
    end

    it_behaves_like "feature plan" do
      get '/admin/api/account_plans/:plan_id/features.:format', action: :index
      delete  '/admin/api/account_plans/:plan_id/features/:id.:format', action: :destroy
    end
  end

  api 'application plan features' do
    let(:featurable) { service }
    let(:scope) { 'ApplicationPlan' }
    let(:plan) { FactoryBot.create(:application_plan, issuer: service) }

    post  '/admin/api/application_plans/:plan_id/features.:format', action: :create do
      include_context "feature params"
    end

    it_behaves_like "feature plan" do
      get '/admin/api/application_plans/:plan_id/features.:format', action: :index
      delete  '/admin/api/application_plans/:plan_id/features/:id.:format', action: :destroy
    end
  end

  api 'service plan features' do
    let(:featurable) { service }
    let(:scope) { 'ServicePlan' }
    let(:plan) { FactoryBot.create(:service_plan, issuer: service) }

    post  '/admin/api/service_plans/:plan_id/features.:format', action: :create do
      include_context "feature params"
    end

    it_behaves_like "feature plan" do
      get '/admin/api/service_plans/:plan_id/features.:format', action: :index
      delete '/admin/api/service_plans/:plan_id/features/:id.:format', action: :destroy
    end
  end


  api 'account features' do
    let(:resource) { FactoryBot.build(:feature, scope: 'Account', featurable: provider) }

    get '/admin/api/features.:format', action: :index
    get '/admin/api/features/:id.:format', action: :show
    delete '/admin/api/features/:id.:format', action: :destroy

    it_behaves_like "feature" do
      post '/admin/api/features.:format', action: :create
      put '/admin/api/features/:id.:format', action: :update
    end

  end

  api 'service features' do
    let(:resource) { FactoryBot.build(:feature, featurable: service) }
    let(:service_id) { service.id }

    get '/admin/api/services/:service_id/features.:format', action: :index
    get '/admin/api/services/:service_id/features/:id.:format', action: :show

    delete '/admin/api/services/:service_id/features/:id.:format', action: :destroy

    it_behaves_like "feature" do
      put '/admin/api/services/:service_id/features/:id.:format', action: :update
      post '/admin/api/services/:service_id/features.:format', action: :create do
        parameter :scope, 'Feature Scope'
        let(:scope) { 'ServicePlan' }
      end
    end
  end

  context do
    let(:resource) { FactoryBot.create(:feature, featurable: featurable, scope: scope) }
    let(:scope) { nil }
    let(:featurable) { provider }

    json(:resource) do
      let(:root) { 'feature' }

      it { should have_properties('id', 'name', 'system_name', 'created_at', 'updated_at') }
      it { should have_links('self') }

      context "account feature" do
        let(:featurable) { provider }
        let(:scope) { 'AccountPlan' }
        it { should have_properties(scope: scope.underscore) }
        it { should_not have_links('service') }
        it { should have_links('self') }
      end

      context "application feature" do
        let(:featurable) { service }
        let(:scope) { 'ApplicationPlan' }
        it { should have_properties(scope: scope.underscore) }
        it { should have_links('self', 'service') }
      end

      context "subscription feature" do
        let(:featurable) { service }
        let(:scope) { 'ServicePlan' }
        it { should have_properties(scope: scope.underscore) }
        it { should have_links('self', 'service') }
      end
    end

    json(:collection) do
      let(:root) { 'features' }
      it { should be_an(Array) }
    end
  end

end

__END__

    admin_api_account_plan_features GET    /admin/api/account_plans/:account_plan_id/features(.:format)             admin/api/account_plan_features#index {:format=>"xml"}
                                    POST   /admin/api/account_plans/:account_plan_id/features(.:format)             admin/api/account_plan_features#create {:format=>"xml"}
     admin_api_account_plan_feature DELETE /admin/api/account_plans/:account_plan_id/features/:id(.:format)         admin/api/account_plan_features#destroy {:format=>"xml"}

admin_api_application_plan_features GET    /admin/api/application_plans/:application_plan_id/features(.:format)     admin/api/application_plan_features#index {:format=>"xml"}
                                    POST   /admin/api/application_plans/:application_plan_id/features(.:format)     admin/api/application_plan_features#create {:format=>"xml"}
 admin_api_application_plan_feature DELETE /admin/api/application_plans/:application_plan_id/features/:id(.:format) admin/api/application_plan_features#destroy {:format=>"xml"}

    admin_api_service_plan_features GET    /admin/api/service_plans/:service_plan_id/features(.:format)             admin/api/service_plan_features#index {:format=>"xml"}
                                    POST   /admin/api/service_plans/:service_plan_id/features(.:format)             admin/api/service_plan_features#create {:format=>"xml"}
     admin_api_service_plan_feature DELETE /admin/api/service_plans/:service_plan_id/features/:id(.:format)         admin/api/service_plan_features#destroy {:format=>"xml"}

                 admin_api_features GET    /admin/api/features(.:format)                                            admin/api/account_features#index {:format=>"xml"}
                                    POST   /admin/api/features(.:format)                                            admin/api/account_features#create {:format=>"xml"}
                  admin_api_feature GET    /admin/api/features/:id(.:format)                                        admin/api/account_features#show {:format=>"xml"}
                                    PUT    /admin/api/features/:id(.:format)                                        admin/api/account_features#update {:format=>"xml"}
                                    DELETE /admin/api/features/:id(.:format)                                        admin/api/account_features#destroy {:format=>"xml"}

         admin_api_service_features GET    /admin/api/services/:service_id/features(.:format)                       admin/api/service_features#index {:format=>"xml"}
                                    POST   /admin/api/services/:service_id/features(.:format)                       admin/api/service_features#create {:format=>"xml"}
          admin_api_service_feature GET    /admin/api/services/:service_id/features/:id(.:format)                   admin/api/service_features#show {:format=>"xml"}
                                    PUT    /admin/api/services/:service_id/features/:id(.:format)                   admin/api/service_features#update {:format=>"xml"}
                                    DELETE /admin/api/services/:service_id/features/:id(.:format)                   admin/api/service_features#destroy {:format=>"xml"}
