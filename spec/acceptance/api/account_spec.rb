# frozen_string_literal: true

require 'rails_helper'

resource "Account" do

  # build the object which will be used for CRUD actions
  let(:account) { FactoryBot.build(:buyer_account, provider_account: provider) }
  let(:payment_detail) { FactoryBot.create(:payment_detail, account: account) }

  let(:resource) do
    FieldsDefinition.create_defaults!(master)
    provider.reload
    account
  end

  let(:expected_provider_fields) { %w[admin_domain domain admin_base_url base_url from_email support_email finance_support_email site_access_code] }

  shared_context "with billing address set up" do
    before do
      provider.fields_definitions.create!({ :target => "Account", :name => 'billing_address',
                                             :label => 'Billing Address', :read_only => true })
      resource.update(billing_address_address1: 'first line', billing_address_address2: 'second line')
      provider.reload
      resource.reload
    end
  end

  shared_context "with credit card details stored" do
    before do
      payment_detail.update(credit_card_partial_number: 1234, credit_card_expires_on: Date.parse('2018-05-08'), credit_card_auth_code: 'anything')
    end
  end

  # define the api namespace and optional formats it supports
  api 'accounts' do
    # get method to the following url will test :index action
    get '/admin/api/accounts.:format', action: :index

    # similar as above, :show action is defined in spec/support/api/crud.rb
    get '/admin/api/accounts/:id.:format', action: :show

    # actions are named as methods in controllers
    delete '/admin/api/accounts/:id.:format', action: :destroy

    # you can pass a block to the definition
    # in the block you can set up parameters valid for that api endpoint
    # and set values for the parameters
    put '/admin/api/accounts/:id.:format', action: :update do
      parameter :name, 'Account Org Name'

      let(:name) { 'some org name' }
    end

    # also you can make custom actions using already defined ones
    get '/admin/api/accounts/find.:format', action: :show do
      parameter :username, 'User username'
      parameter :email, 'User email address'

      let(:username) { resource.users.first.username }
    end

    # or you can just say that it is resource or collection
    # and appropriate callbacks and values will be set in place
    put '/admin/api/accounts/:id/make_pending.:format' do
      include_context "resource"

      before { resource.approve! }
      before { resource.state.should_not == "pending" }

      # the response code and body are checked automatically
      # you can adjust it by setting:
      #   status: number # status code
      #   body: boolean # if body should be sent or not

      request "Make #{model} pending" do
        resource.reload.state == "pending"
      end
    end

    put '/admin/api/accounts/:id/approve.:format' do
      include_context "resource"
      before { resource.make_pending! }
      before { resource.state.should_not == "approved" }

      request "Approve #{model}" do
        resource.reload.state == "approved"
      end
    end

    put '/admin/api/accounts/:id/reject.:format' do
      include_context "resource"
      before { resource.make_pending! }
      before { resource.state.should_not == "rejected" }

      request "Reject #{model}" do
        resource.reload.state == "rejected"
      end
    end

    post '/admin/api/signup.:format', action: :create do
      let(:serialized) { representer.send(serialization_format, user_options: { with_apps: true }) }

      parameter :org_name, 'Organization Name of the buyer account'
      parameter :username, 'Username od the admin user (on the new buyer account)'
      parameter :email, 'Email of the admin user'
      parameter :password, 'Password of the admin user'

      let(:password) { 'superSecret1234#' }
      let(:email) { 'email@example.com' }
      let(:username) { 'new_user' }
      let(:org_name) { 'New Signup' }
    end

  end

  # we use roar gem and it's representers to extend our objects
  # the extension is done by the responder - app/lib/three_scale/responder.rb
  #
  # thee representers are in app/representers/ and their purpose is:
  #
  # * extract serialization from the model
  # * have hypermedia links in the json api
  # * act as decorator for the model

  # for testing json/xml output:
  #
  # these actions are for testing json/xml output
  # json(:resource) means that the subject of the context will be:
  # resource.extend(representer).to_json
  json(:resource) do
    let(:root) { 'account' }

    context 'buyer account' do
      it do
        should have_properties('id', 'org_name').from(resource)
        should have_properties('state', 'credit_card_stored').from(resource)
        should have_properties('created_at', 'updated_at')
        should have_links('self', 'users')
      end

      context 'if billing address is enabled' do
        include_context 'with billing address set up'

        it do
          should have_properties('billing_address')
          subject.fetch('billing_address').should include('address1' => 'first line', 'address2' => 'second line')
        end
      end

      context 'if scheduled_for_deletion' do
        let(:resource) { FactoryBot.build(:provider_account, state: 'scheduled_for_deletion', state_changed_at: Time.zone.now.beginning_of_day) }
        it { should have_properties(%w[state deletion_date]) }
      end

      context 'if credit card details stored' do
        include_context 'with credit card details stored'
        it { should have_properties('credit_card_partial_number', 'credit_card_expires_on').from(resource)}
      end
    end

    context 'provider account' do
      let(:resource) do
        FactoryBot.build(:provider_account, support_email: 'support@email.com',
                          finance_support_email: 'finance@email.com', site_access_code: 'access-code')
      end

      it { should have_properties(expected_provider_fields).from(resource) }
    end

  end

  # collection is similar as resource, but the object is:
  # [resource].extend(collection_representer).to_json
  json(:collection) do
    let(:root) { 'accounts' }
    it { should be_an(Array) }
  end

  xml(:resource) do
    context 'buyer account' do
      it('has root') { should have_tag('account') }

      it { should have_tag('monthly_billing_enabled') }
      it { should have_tag('monthly_charging_enabled') }

      context 'if billing address is enabled' do
        include_context 'with billing address set up'

        subject { xml.root }

        it 'should have billing address tags' do
          should have_tag('billing_address') {
            with_tag 'address1', :text => 'first line'
            with_tag 'address2', :text => 'second line'
          }
        end
      end

      context 'if scheduled_for_deletion' do
        let(:resource) { FactoryBot.build(:provider_account, state: 'scheduled_for_deletion', state_changed_at: Time.zone.now) }
        it { should have_tags(%w[state deletion_date]).from(resource) }
      end

      context 'if credit card details stored' do
        include_context 'with credit card details stored'
        it { should have_tag('credit_card_partial_number') }
        it { should have_tag('credit_card_expires_on') }
      end
    end

    context 'provider account' do
      let(:resource) do
        FactoryBot.build(:provider_account, support_email: 'support@email.com',
                          finance_support_email: 'finance@email.com', site_access_code: 'access-code')
      end

      it do
        should have_tags(expected_provider_fields - %w[domain admin_domain]).from(resource)

        should have_tag('domain', resource.external_domain)
        should have_tag('admin_domain', resource.external_admin_domain)
      end
    end
  end
end


__END__
admin_api_accounts GET    /admin/api/accounts(.:format)      admin/api/accounts#index {:format=>"xml"}
 admin_api_account GET    /admin/api/accounts/:id(.:format)  admin/api/accounts#show {:format=>"xml"}
                   PUT    /admin/api/accounts/:id(.:format)  admin/api/accounts#update {:format=>"xml"}
                   DELETE /admin/api/accounts/:id(.:format)  admin/api/accounts#destroy {:format=>"xml"}

       find_admin_api_accounts GET    /admin/api/accounts/find(.:format)                admin/api/accounts#find {:format=>"xml"}
 change_plan_admin_api_account PUT    /admin/api/accounts/:id/change_plan(.:format)     admin/api/accounts#change_plan {:format=>"xml"}
make_pending_admin_api_account PUT    /admin/api/accounts/:id/make_pending(.:format)    admin/api/accounts#make_pending {:format=>"xml"}
     approve_admin_api_account PUT    /admin/api/accounts/:id/approve(.:format)         admin/api/accounts#approve {:format=>"xml"}
      reject_admin_api_account PUT    /admin/api/accounts/:id/reject(.:format)          admin/api/accounts#reject {:format=>"xml"}

 buy_admin_api_account_application_plan POST   /admin/api/accounts/:account_id/application_plans/:id/buy(.:format) admin/api/buyers_application_plans#buy {:format=>"xml"}
    admin_api_account_application_plans GET    /admin/api/accounts/:account_id/application_plans(.:format)         admin/api/buyers_application_plans#index {:format=>"xml"}
   admin_api_account_buyer_account_plan GET    /admin/api/accounts/:account_id/plan(.:format)                      admin/api/buyer_account_plans#show {:format=>"xml"}
     buy_admin_api_account_service_plan POST   /admin/api/accounts/:account_id/service_plans/:id/buy(.:format)     admin/api/buyers_service_plans#buy {:format=>"xml"}
        admin_api_account_service_plans GET    /admin/api/accounts/:account_id/service_plans(.:format)             admin/api/buyers_service_plans#index {:format=>"xml"}
