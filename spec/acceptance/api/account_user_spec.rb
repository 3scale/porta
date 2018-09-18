require 'spec_helper'

# merge this one with user_spec.rb ?

resource "User" do

  let(:buyer) { Factory(:buyer_account, provider_account: provider) }
  let(:user) { Factory.build(:user, account: buyer) }

  let(:resource) do
    FieldsDefinition.create_defaults(master)
    provider.reload
    user
  end

  let(:account_id) { buyer.id }

  api 'account user' do
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

  # tested in user_spec.rb
end

__END__
                         admin_admin_api_account_user PUT    /admin/api/accounts/:account_id/users/:id/admin(.:format)                                              admin/api/buyers_users#admin {:format=>"xml"}
                        member_admin_api_account_user PUT    /admin/api/accounts/:account_id/users/:id/member(.:format)                                             admin/api/buyers_users#member {:format=>"xml"}
                       suspend_admin_api_account_user PUT    /admin/api/accounts/:account_id/users/:id/suspend(.:format)                                            admin/api/buyers_users#suspend {:format=>"xml"}
                      activate_admin_api_account_user PUT    /admin/api/accounts/:account_id/users/:id/activate(.:format)                                           admin/api/buyers_users#activate {:format=>"xml"}
                     unsuspend_admin_api_account_user PUT    /admin/api/accounts/:account_id/users/:id/unsuspend(.:format)                                          admin/api/buyers_users#unsuspend {:format=>"xml"}
                              admin_api_account_users GET    /admin/api/accounts/:account_id/users(.:format)                                                        admin/api/buyers_users#index {:format=>"xml"}
                                                      POST   /admin/api/accounts/:account_id/users(.:format)                                                        admin/api/buyers_users#create {:format=>"xml"}
                               admin_api_account_user GET    /admin/api/accounts/:account_id/users/:id(.:format)                                                    admin/api/buyers_users#show {:format=>"xml"}
                                                      PUT    /admin/api/accounts/:account_id/users/:id(.:format)                                                    admin/api/buyers_users#update {:format=>"xml"}
                                                      DELETE /admin/api/accounts/:account_id/users/:id(.:format)                                                    admin/api/buyers_users#destroy {:format=>"xml"}
