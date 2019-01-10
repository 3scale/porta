require 'rails_helper'

resource "EndUser", transactions: false do

  let(:service) { provider.services.default }
  let(:plan) { FactoryBot.create(:end_user_plan, service: service) }
  let(:resource) { EndUser.new(service, username: 'some-end-user', plan_id: plan.id) }

  let(:service_id) { service.id }

  before do
    provider.settings.allow_end_users!
    resource.stubs(:save!).returns(resource)
    EndUser.stubs(:find).with(service, resource.username).returns(resource)
  end

  api 'end user' do
    get "/admin/api/services/:service_id/end_users/:id.:format", action: :show

    post "/admin/api/services/:service_id/end_users.:format", action: :create do
      parameter :username, 'End User Name'
      parameter :plan_id, 'End User Plan ID'

      let(:username) { 'uuid-like-thingy' }
      let(:plan_id) { plan.id }

      before do
        other_user = EndUser.new(service, {username: username, plan_id: plan.id})
        EndUser.stubs(:create).returns(other_user)
        EndUser.stubs(:find).with(service, other_user.username).returns(other_user)
      end

      let(:serializable) { EndUser.find(service, username) }
    end

    put "/admin/api/services/:service_id/end_users/:id/change_plan.:format", action: true do
      include_context "resource"

      before do
        resource.stubs(:new_record?).returns(false)
        EndUser.stubs(:find).with(service, resource.username).returns(resource)
      end

      let(:new_plan) { FactoryBot.create(:end_user_plan, issuer: service) }

      parameter :plan_id, 'End User Plan ID'
      let(:plan_id) { new_plan.id }

      request "Change plan of #{model}" do
        resource = EndUser.new(service, {username: 'some-end-user', plan_id: new_plan.id})

        response_body.should == serialized
        resource.plan.should == new_plan
        status.should == 200
      end
    end

    delete "/admin/api/services/:service_id/end_users/:id", action: :destroy
  end

  json(:resource) do
    let(:root) { 'end_user' }
    it { should include('username' => resource.id) }
    it { should have_links('plan', 'service', 'self') }
  end

  json(:collection) do
    let(:root) { 'end_users' }
    it { should be_an(Array) }
  end
end

__END__

               change_plan_admin_api_service_end_user PUT    /admin/api/services/:service_id/end_users/:id/change_plan(.:format)                                    admin/api/services/end_users#change_plan {:format=>"xml"}
                          admin_api_service_end_users POST   /admin/api/services/:service_id/end_users(.:format)                                                    admin/api/services/end_users#create {:format=>"xml"}
                           admin_api_service_end_user GET    /admin/api/services/:service_id/end_users/:id(.:format)                                                admin/api/services/end_users#show {:format=>"xml"}
                                                      DELETE /admin/api/services/:service_id/end_users/:id(.:format)                                                admin/api/services/end_users#destroy {:format=>"xml"}
