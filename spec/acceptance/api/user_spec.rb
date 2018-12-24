require 'spec_helper'

resource "User" do

  let(:resource) { FactoryBot.build(:user, account: provider) }
  let(:buyer) { FactoryBot.create(:buyer_account, provider_account: provider) }

  before do
    provider.settings.allow_multiple_users!
  end

  api 'user' do

    get '/admin/api/users/:id.:format', action: :show

    delete '/admin/api/users/:id', action: :destroy

    get '/admin/api/users.:format', action: :index do
      let(:serializable) { [ provider.users.first, resource ] }

      context do
        parameter :state, 'Filter by state'
        parameter :role, 'Filter by role'

        let(:state) { 'active' }
        let(:role) { 'admin' }

        before { resource.save }
        let(:serializable) { provider.users.where(state: state, role: role) }

        request "List approved admin #{models}" do
          response_body.should == serialized
          status.should == 200
          serializable.size.should == 1
        end
      end
    end

    context do
      parameter :username, 'Username'
      parameter :email, 'Valid email address'
      parameter :password, 'Desired Password'

      let(:username) { 'bob' }
      let(:email) { 'bob@example.com' }

      post '/admin/api/users.:format', action: :create
      put '/admin/api/users/:id.:format', action: :update
    end

    # roles
    put '/admin/api/users/:id/member.:format', action: :member do
      before { resource.make_admin }
    end

    put '/admin/api/users/:id/admin.:format', action: :admin do
      before { resource.make_member }
    end

    # states
    put '/admin/api/users/:id/activate.:format', action: :activate do
      before { resource.state.should == 'pending' }
    end

    put '/admin/api/users/:id/suspend.:format', action: :suspend do
      before { resource.activate! }
    end

    put '/admin/api/users/:id/unsuspend.:format', action: :unsuspend do
      before { resource.activate! && resource.suspend! }
    end
  end

  api 'buyer user' do

    let(:account_id) { buyer.id }

    let (:user) { FactoryBot.build(:user, account: buyer) }

    let(:resource) do
      FieldsDefinition.create_defaults(master)
      provider.reload
      user
    end

    get '/admin/api/accounts/:account_id/users/:id.:format', action: :show
    delete '/admin/api/accounts/:account_id/users/:id', action: :destroy

    get '/admin/api/accounts/:account_id/users.:format', action: :index do
      let(:serializable) { [ buyer.users.first, resource ] }

      context do
        parameter :state, 'Filter by state'
        parameter :role, 'Filter by role'

        let(:state) { 'active' }
        let(:role) { 'admin' }

        before { resource.save }
        let(:serializable) { buyer.users.where(state: state, role: role) }

        request "List approved admin #{models}" do
          response_body.should == serialized
          status.should == 200
          serializable.size.should == 1
        end
      end
    end

    context do
      parameter :username, 'Username'
      parameter :email, 'Valid email address'
      parameter :password, 'Desired Password'

      let(:username) { 'bob' }
      let(:email) { 'bob@example.com' }

      post '/admin/api/accounts/:account_id/users.:format', action: :create
      put '/admin/api/accounts/:account_id/users/:id.:format', action: :update
    end

    # roles
    put '/admin/api/accounts/:account_id/users/:id/member.:format', action: :member do
      before { resource.make_admin }
    end

    put '/admin/api/accounts/:account_id/users/:id/admin.:format', action: :admin do
      before { resource.make_member }
    end

    # states
    put '/admin/api/accounts/:account_id/users/:id/activate.:format', action: :activate do
      before { resource.state.should == 'pending' }
    end

    put '/admin/api/accounts/:account_id/users/:id/suspend.:format', action: :suspend do
      before { resource.activate! }
    end

    put '/admin/api/accounts/:account_id/users/:id/unsuspend.:format', action: :unsuspend do
      before { resource.activate! && resource.suspend! }
    end
  end

  json(:resource) do
    let(:root) { 'user' }

    let(:user) { FactoryBot.create(:user, account: provider) }

    # creating new db records for fields that are in db is pathetic as it can get
    let(:resource) do
      FieldsDefinition.create_defaults(master)
      provider.reload
      user
    end

    it { should include('id' => user.id, 'state' => user.state, 'role' => user.role.to_s) }
    it { should include('email' => user.email, 'username' => user.username) }
    # TODO: test different conditions like signup types

    context "provider user" do
      let(:resource) { FactoryBot.create(:user, account: provider) }
      it { should have_links('self') }
      it { should_not have_links('account') }
    end

    context "buyer user" do
      let(:resource) { FactoryBot.create(:user, account: buyer) }
      it { should have_links('self', 'account') }
    end
  end

  json(:collection) do
    let(:root) { 'users' }
    it { should be_an(Array) }
  end
end

__END__
            admin_admin_api_user PUT    /admin/api/users/:id/admin(.:format)                                       admin/api/users#admin {:format=>"xml"}
           member_admin_api_user PUT    /admin/api/users/:id/member(.:format)                                      admin/api/users#member {:format=>"xml"}
          suspend_admin_api_user PUT    /admin/api/users/:id/suspend(.:format)                                     admin/api/users#suspend {:format=>"xml"}
         activate_admin_api_user PUT    /admin/api/users/:id/activate(.:format)                                    admin/api/users#activate {:format=>"xml"}
        unsuspend_admin_api_user PUT    /admin/api/users/:id/unsuspend(.:format)                                   admin/api/users#unsuspend {:format=>"xml"}
                 admin_api_users GET    /admin/api/users(.:format)                                                 admin/api/users#index {:format=>"xml"}
                                 POST   /admin/api/users(.:format)                                                 admin/api/users#create {:format=>"xml"}
                  admin_api_user GET    /admin/api/users/:id(.:format)                                             admin/api/users#show {:format=>"xml"}
                                 PUT    /admin/api/users/:id(.:format)                                             admin/api/users#update {:format=>"xml"}
                                 DELETE /admin/api/users/:id(.:format)                                             admin/api/users#destroy {:format=>"xml"}

    admin_admin_api_account_user PUT    /admin/api/accounts/:account_id/users/:id/admin(.:format)                  admin/api/buyers_users#admin {:format=>"xml"}
   member_admin_api_account_user PUT    /admin/api/accounts/:account_id/users/:id/member(.:format)                 admin/api/buyers_users#member {:format=>"xml"}
  suspend_admin_api_account_user PUT    /admin/api/accounts/:account_id/users/:id/suspend(.:format)                admin/api/buyers_users#suspend {:format=>"xml"}
 activate_admin_api_account_user PUT    /admin/api/accounts/:account_id/users/:id/activate(.:format)               admin/api/buyers_users#activate {:format=>"xml"}
unsuspend_admin_api_account_user PUT    /admin/api/accounts/:account_id/users/:id/unsuspend(.:format)              admin/api/buyers_users#unsuspend {:format=>"xml"}
         admin_api_account_users GET    /admin/api/accounts/:account_id/users(.:format)                            admin/api/buyers_users#index {:format=>"xml"}
                                 POST   /admin/api/accounts/:account_id/users(.:format)                            admin/api/buyers_users#create {:format=>"xml"}
          admin_api_account_user GET    /admin/api/accounts/:account_id/users/:id(.:format)                        admin/api/buyers_users#show {:format=>"xml"}
                                 PUT    /admin/api/accounts/:account_id/users/:id(.:format)                        admin/api/buyers_users#update {:format=>"xml"}
                                 DELETE /admin/api/accounts/:account_id/users/:id(.:format)                        admin/api/buyers_users#destroy {:format=>"xml"}
