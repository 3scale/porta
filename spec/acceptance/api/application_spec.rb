require 'rails_helper'

resource "Cinstance" do

  let(:service) { provider.services.default }
  let(:plan) { FactoryBot.create(:application_plan, service: service) }
  let(:buyer) { FactoryBot.create(:buyer_account, provider_account: provider) }
  let(:resource) { FactoryBot.create(:cinstance, user_account: buyer, plan: plan) }
  let(:other_plan) { FactoryBot.create(:application_plan, service: service) }

  shared_examples "find application" do
    context 'with app id', action: :show do
      before { service.update_attribute(:backend_version, '2'); resource.reload }
      parameter :app_id, 'App ID'
      let(:app_id) { resource.application_id }
    end

    context 'with user key', action: :show do
      before do
        service.update_attribute :backend_version, '1'
        resource.update_attribute :user_key, 'some-key'
      end
      parameter :user_key, 'User Key'
      let(:user_key) { resource.user_key }
    end
  end

  shared_context "first traffic is not nil" do
    let (:first_traffic) { Time.zone.parse('2017-11-20 10:00:00 UTC') }
    let (:first_daily_traffic) { Time.zone.parse('2017-11-21 10:00:00 UTC') }
    before do
      resource.update_attributes(first_traffic_at: first_traffic, first_daily_traffic_at: first_daily_traffic)
    end
  end

  api 'application' do

    let!(:app1) {FactoryBot.create(:cinstance, user_account: buyer, plan: plan, first_daily_traffic_at: DateTime.parse('2014-01-01'))}
    let!(:app2) {FactoryBot.create(:cinstance, user_account: buyer, plan: plan, first_daily_traffic_at: DateTime.parse('2013-01-01'))}

    get '/admin/api/applications.:format', action: :index do
      parameter(:inactive_since, "Date to filter applications")
      parameter(:active_since,   "Date to filter applications")

      let(:inactive_since) { '2014-05-05'}
      let(:collection) { [app1, app2] }
    end

    get '/admin/api/applications/find.:format', :resource do
      context 'with id', action: :show do
        parameter :id, 'Application ID'
        let(:id) { resource.id }
      end

      include_examples "find application"
    end
  end

  api 'buyer application' do
    let(:account_id) { buyer.id }

    get '/admin/api/accounts/:account_id/applications.:format', action: :index

    get '/admin/api/accounts/:account_id/applications/find.:format' do
      include_examples "find application"
    end

    get '/admin/api/accounts/:account_id/applications/:id.:format', action: :show
    delete '/admin/api/accounts/:account_id/applications/:id.:format', action: :destroy

    context do
      parameter :plan_id, "Application Plan ID"
      parameter :name, 'Application Name'
      parameter :description, 'Application Description'
      parameter :user_key, 'Application User Key'
      parameter :application_id, 'Application app_id'
      parameter :application_key, 'Application app_key'

      put '/admin/api/accounts/:account_id/applications/:id.:format', action: :update do
        let(:description) { 'new one' }
        after { resource.description.should == 'new one' }
      end

      post '/admin/api/accounts/:account_id/applications.:format', action: :create do
        let(:plan_id) { other_plan.id }

        example_request "Set application_key and user_key" do
          do_request(user_key: 'barbar', application_key: 'foobar')

          expect(status).to eq(201)
          expect(serializable.user_key).to eq('barbar')
          expect(serializable.keys).to eq(['foobar'])
        end

        example_request "Create #{model} with many application keys" do
          do_request(application_key: ['foobar', 'dazbar'])

          expect(status).to eq(201)
          expect(serializable.keys.sort).to eq(['foobar', 'dazbar'].sort)
        end
      end
    end

    context 'plan actions', :resource do
      let(:resource_representer) { 'ApplicationPlanRepresenter' }

      put '/admin/api/accounts/:account_id/applications/:id/change_plan.:format' do
        let(:serializable) { other_plan }
        parameter :plan_id, "Application Plan ID"
        let(:plan_id) { other_plan.id }

        request "Change plan of #{model}" do
          response_body.should == serialized
          resource.reload.plan_id.should == other_plan.id
        end
      end

      put '/admin/api/accounts/:account_id/applications/:id/customize_plan.:format' do
        let(:serializable) { resource.plan }

        request "Customize plan of #{model}" do
          resource.reload.plan.should_not == plan
        end
      end

      put '/admin/api/accounts/:account_id/applications/:id/decustomize_plan.:format' do
        let(:serializable) { plan }
        before { resource.customize_plan! }
        before { resource.plan.should_not == plan }

        request "Decustomize plan of #{model}" do
          resource.reload.plan.should == plan
        end
      end
    end

    put '/admin/api/accounts/:account_id/applications/:id/accept.:format', action: :activate do
      let(:desired_state) { 'live' }
      before { resource.update_attribute(:state, 'pending') }
    end

    put '/admin/api/accounts/:account_id/applications/:id/suspend.:format', action: :suspend do
      before { resource.state.should == 'live' }
    end

    put '/admin/api/accounts/:account_id/applications/:id/resume.:format', action: :unsuspend do
      let(:desired_state) { 'live' }
      before { resource.suspend! }
    end
  end

  api 'application keys', model_name: 'ApplicationKey'  do
    let(:account_id) { buyer.id }
    let(:application_id) { resource.save! and resource.id }

    post "/admin/api/accounts/:account_id/applications/:application_id/keys.:format", action: :create do
      parameter :key, 'app_key to be created'
      let(:key) { 'some-key' }
    end

    delete "/admin/api/accounts/:account_id/applications/:application_id/keys/:key.:format", action: :destroy do
      let(:app_key) { FactoryBot.create(:application_key, application: resource) }

      parameter :key, 'app_key to be deleted'
      let(:key) { app_key.value }
    end
  end

  api 'referrer filters', model_name: 'ReferrerFilter' do
    let(:account_id) { buyer.id }
    let(:application_id) { resource.save! and resource.id }

    post "/admin/api/accounts/:account_id/applications/:application_id/referrer_filters.:format", action: :create do
      parameter :referrer_filter, 'referrer_filter to be created'
      let(:referrer_filter) { 'some-filter' }
    end

    delete "/admin/api/accounts/:account_id/applications/:application_id/referrer_filters/:filter_id.:format", action: :destroy do
      let(:filter) { FactoryBot.create(:referrer_filter, application: resource) }
      parameter :filter_id, 'Referrer Filter ID'
      let(:filter_id) { filter.id }
    end
  end

  json(:resource) do
    let(:root) { 'application' }

    let(:resource) do
      buyer = FactoryBot.create :buyer_account, provider_account: provider
      buyer.buy! provider.default_account_plan
      buyer.bought_service_contracts.create! :plan => service.service_plans.first
      buyer.buy! plan

      buyer.bought_cinstances.last
    end

    it { should have_properties('id', 'state', 'name', 'plan_id', 'description', 'end_user_required', 
                      'service_id', 'first_traffic_at', 'first_daily_traffic_at').from(resource) }
    it { should have_links('self', 'account', 'plan', 'keys', 'referrer_filters', 'service') }

    it { should include('account_id' => resource.buyer.id )}

    it { subject.fetch('enabled').should == resource.enabled? }

    context "if first traffic is not nil" do
      include_context "first traffic is not nil"

      it { should include('first_traffic_at' => first_traffic.as_json, 
                          'first_daily_traffic_at' => first_daily_traffic.as_json) }
    end

    context "in oauth mode" do
      before { resource.service.update_attribute(:backend_version, 'oauth') }
      it { should include('redirect_url' => resource.redirect_url,
                          'client_id' => resource.application_id,
                          'client_secret' => resource.keys.first) }
    end

    context "in v1 mode" do
      before { resource.service.update_attribute(:backend_version, '1') }
      it do 
        should include('user_key' => resource.user_key,
                          'provider_verification_key' => resource.provider_public_key) 
      end
    end

    context "in v2 mode" do
      before { resource.service.update_attribute(:backend_version, '2') }
      it { should include('application_id' => resource.application_id) }
    end

  end

  json(:collection) do
    let(:root) { 'applications' }
    it { should be_an(Array) }
  end

  xml(:resource) do
    before do
      resource.update_attributes(name: 'app name', description: 'app description')
    end

    it('has root') { should have_tag('application') }

    context "root" do
      subject { xml.root }
      it { should have_tag('id') }
      it { should have_tag('state') }
      it { should have_tag('name') }
      it { should have_tag('description') }
      it { should have_tag('user_account_id') }
      it { should have_tag('first_traffic_at') }
      it { should have_tag('first_daily_traffic_at') }
      it { should have_tag('end_user_required') }
      it { should have_tag('service_id') }
      it { should have_tag('plan') }
    end

    context "if first traffic is not nil" do
      include_context "first traffic is not nil"

      it { should have_tag('first_traffic_at', :text => '2017-11-20T10:00:00Z') }
      it { should have_tag('first_daily_traffic_at', :text => '2017-11-21T10:00:00Z') }
    end
  end

end

__END__
                   find_admin_api_applications GET /admin/api/applications/find(.:format)                                      admin/api/applications#find {:format=>"xml"}
                        admin_api_applications GET /admin/api/applications(.:format)                                           admin/api/applications#index {:format=>"xml"}

                admin_api_account_applications GET  /admin/api/accounts/:account_id/applications(.:format)                      admin/api/buyers_applications#index {:format=>"xml"}
                                               POST /admin/api/accounts/:account_id/applications(.:format)                      admin/api/buyers_applications#create {:format=>"xml"}
                 admin_api_account_application GET  /admin/api/accounts/:account_id/applications/:id(.:format)                  admin/api/buyers_applications#show {:format=>"xml"}
                                               PUT  /admin/api/accounts/:account_id/applications/:id(.:format)                  admin/api/buyers_applications#update {:format=>"xml"}
           find_admin_api_account_applications GET  /admin/api/accounts/:account_id/applications/find(.:format)                 admin/api/buyers_applications#find {:format=>"xml"}
     change_plan_admin_api_account_application PUT  /admin/api/accounts/:account_id/applications/:id/change_plan(.:format)      admin/api/buyers_applications#change_plan {:format=>"xml"}
  customize_plan_admin_api_account_application PUT  /admin/api/accounts/:account_id/applications/:id/customize_plan(.:format)   admin/api/buyers_applications#customize_plan {:format=>"xml"}
decustomize_plan_admin_api_account_application PUT  /admin/api/accounts/:account_id/applications/:id/decustomize_plan(.:format) admin/api/buyers_applications#decustomize_plan {:format=>"xml"}
          accept_admin_api_account_application PUT  /admin/api/accounts/:account_id/applications/:id/accept(.:format)           admin/api/buyers_applications#accept {:format=>"xml"}
         suspend_admin_api_account_application PUT  /admin/api/accounts/:account_id/applications/:id/suspend(.:format)          admin/api/buyers_applications#suspend {:format=>"xml"}
          resume_admin_api_account_application PUT  /admin/api/accounts/:account_id/applications/:id/resume(.:format)           admin/api/buyers_applications#resume {:format=>"xml"}


            admin_api_account_application_keys POST   /admin/api/accounts/:account_id/applications/:application_id/keys(.:format)                  admin/api/buyer_application_keys#create {:format=>"xml"}
             admin_api_account_application_key DELETE /admin/api/accounts/:account_id/applications/:application_id/keys/:id(.:format)              admin/api/buyer_application_keys#destroy {:format=>"xml"}

admin_api_account_application_referrer_filters POST   /admin/api/accounts/:account_id/applications/:application_id/referrer_filters(.:format)      admin/api/buyer_application_referrer_filters#create {:format=>"xml"}
 admin_api_account_application_referrer_filter DELETE /admin/api/accounts/:account_id/applications/:application_id/referrer_filters/:id(.:format)  admin/api/buyer_application_referrer_filters#destroy {:format=>"xml"}
