require 'spec_helper'

resource "AccountPlan" do

  let(:resource) { Factory.build(:account_plan, issuer: provider) }

  api 'account plan' do

    get "/admin/api/account_plans.:format", action: :index do
      let(:serializable) { [provider.account_plans.default, resource] }
    end

    get "/admin/api/account_plans/:id.:format", action: :show

    post "/admin/api/account_plans.:format", action: :create do
      parameter :name, 'Account Plan Name'
      let(:name) { 'Example Plan' }
    end

    put "/admin/api/account_plans/:id.:format", action: :update do
      parameter :name, 'Account Plan Name'
      let(:name) { 'New Name' }
    end

    put "/admin/api/account_plans/:id/default.:format", action: :default do
      let(:default) { provider.reload.default_account_plan }
    end

    delete "/admin/api/account_plans/:id", action: :destroy
  end

  api 'buyer account plan' do
    let(:account) { Factory(:buyer_account, provider_account: provider) }
    let(:account_id) { account.id }

    put '/admin/api/accounts/:account_id/change_plan.:format', :resource do
      before { resource.save! }
      before { resource.create_contract_with!(account) }

      parameter :plan_id, 'Plan ID'

      let(:other_plan) { Factory(:account_plan, issuer: provider) }
      let(:plan_id) { other_plan.id }
      let(:serializable) { other_plan }

      request "Change #{model}" do
        other_plan.state.should_not == 'published'
        account.reload.bought_account_plan.should == other_plan
      end
    end

    get '/admin/api/accounts/:account_id/plan.:format', action: :show do
      before { resource.create_contract_with!(account) }
    end
  end

  json(:resource) do
    let(:root) { 'account_plan' }

    it { should have_properties('id', 'name', 'state', 'created_at', 'updated_at').from(resource) }
    it { should have_properties('setup_fee', 'cost_per_month').from(resource) }
    it { should have_properties('trial_period_days', 'cancellation_period', 'default').from(resource) }
  end

  json(:collection) do
    let(:root) { 'plans' }
    it { should be_an(Array) }
  end
end

__END__

default_admin_api_account_plan PUT    /admin/api/account_plans/:id/default(.:format) admin/api/account_plans#default {:format=>"xml"}
       admin_api_account_plans GET    /admin/api/account_plans(.:format)             admin/api/account_plans#index {:format=>"xml"}
                               POST   /admin/api/account_plans(.:format)             admin/api/account_plans#create {:format=>"xml"}
        admin_api_account_plan GET    /admin/api/account_plans/:id(.:format)         admin/api/account_plans#show {:format=>"xml"}
                               PUT    /admin/api/account_plans/:id(.:format)         admin/api/account_plans#update {:format=>"xml"}
                               DELETE /admin/api/account_plans/:id(.:format)         admin/api/account_plans#destroy {:format=>"xml"}

admin_api_account_buyer_account_plan GET    /admin/api/accounts/:account_id/plan(.:format) admin/api/buyer_account_plans#show {:format=>"xml"}
       change_plan_admin_api_account PUT    /admin/api/accounts/:id/change_plan(.:format)  admin/api/accounts#change_plan {:format=>"xml"}
