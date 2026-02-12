# frozen_string_literal: true

require 'test_helper'

# TODO: Split this file as it takes too long.
class Admin::Api::BuyerUsersTest < ActionDispatch::IntegrationTest
  include FieldsDefinitionsHelpers

  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    @provider.default_account_plan = @provider.account_plans.first

    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @buyer.buy! @provider.default_account_plan

    @member = FactoryBot.create(:user, account: @buyer, role: "member")

    FactoryBot.create :user

    host! @provider.external_admin_domain
  end

  class AccessTokenWithCallbacks < ActionDispatch::IntegrationTest
    def setup
      @provider = FactoryBot.create(:simple_provider)
      @buyer    = FactoryBot.create(:simple_buyer, provider_account: @provider)

      host! @provider.external_admin_domain
    end

    test 'create action should not logout a current user' do
      Settings::Switch.any_instance.stubs(:allowed?).returns(true)
      user  = FactoryBot.create(:admin, account: @provider)
      token = FactoryBot.create(:access_token, owner: user, scopes: ['account_management'])

      User.any_instance.expects(:forget_me).never

      post admin_api_account_users_path(@buyer, format: :xml), params: { username: 'alex', email: 'alex@alaska.hu', access_token: token.value }
      assert_response :success
    end
  end

  # Access token

  test 'index (access_token)' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    user  = FactoryBot.create(:member, account: @provider)
    token = FactoryBot.create(:access_token, owner: user)

    get admin_api_account_users_path(@buyer, format: :xml), params: { access_token: token.value }
    assert_response :forbidden

    user.admin_sections = ['partners']
    user.save!
    get admin_api_account_users_path(@buyer, format: :xml), params: { access_token: token.value }
    assert_response :forbidden

    token.scopes = ['account_management']
    token.save!
    get admin_api_account_users_path(@buyer, format: :xml), params: { access_token: token.value }
    assert_response :success
  end

  test 'show (access_token)' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryBot.create(:access_token, owner: user, scopes: ['account_management'])

    get admin_api_account_user_path(@buyer, id: @member.id, format: :xml), params: { access_token: token.value }
    assert_response :success

    user.role = 'admin'
    user.save!
    get admin_api_account_user_path(@buyer, id: @member.id, format: :xml), params: { access_token: token.value }
    assert_response :success
  end

  test 'update (access_token)' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryBot.create(:access_token, owner: user, scopes: ['account_management'])

    put admin_api_account_user_path(@buyer.id, id: @member.id, format: :xml), params: { username: 'Alex', access_token: token.value }
    assert_response :success

    user.role = 'admin'
    user.save!
    put admin_api_account_user_path(@buyer.id, id: @member.id, format: :xml), params: { username: 'Alex', access_token: token.value }
    assert_response :success
  end

  test 'create (access_token)' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryBot.create(:access_token, owner: user, scopes: ['account_management'])

    post admin_api_account_users_path(@buyer, format: :xml), params: { username: 'alex', email: 'alex@alaska.hu', access_token: token.value }
    assert_response :forbidden

    user.role = 'admin'
    user.save!
    post admin_api_account_users_path(@buyer, format: :xml), params: { username: 'alex', email: 'alex@alaska.hu', access_token: token.value }
    assert_response :success
  end

  test 'update/activate (access_token)' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryBot.create(:access_token, owner: user, scopes: ['account_management'])

    put admin_api_account_user_path(@buyer.id, id: @member.id, format: :xml), params: { username: 'alex', access_token: token.value }
    assert_response :success
    put activate_admin_api_account_user_path(@buyer.id, id: @member.id, format: :xml), params: { username: 'alex', access_token: token.value }
    assert_response :success

    user.role = 'admin'
    user.save!
    put admin_api_account_user_path(@buyer.id, id: @member.id, format: :xml), params: { username: 'alex', access_token: token.value }
    assert_response :success
    put activate_admin_api_account_user_path(@buyer.id, id: @member.id, format: :xml), params: { username: 'alex', access_token: token.value }
    assert_response :success
  end

  test 'admin/member (access_token)' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryBot.create(:access_token, owner: user, scopes: ['account_management'])

    put admin_admin_api_account_user_path(@buyer.id, id: @member.id, format: :xml), params: { username: 'alex', access_token: token.value }
    assert_response :success
    put member_admin_api_account_user_path(@buyer.id, id: @member.id, format: :xml), params: { username: 'alex', access_token: token.value }
    assert_response :success

    user.role = 'admin'
    user.save!
    put admin_admin_api_account_user_path(@buyer.id, id: @member.id, format: :xml), params: { username: 'alex', access_token: token.value }
    assert_response :success
    put member_admin_api_account_user_path(@buyer.id, id: @member.id, format: :xml), params: { username: 'alex', access_token: token.value }
    assert_response :success
  end

  test 'destroy (access_token)' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryBot.create(:access_token, owner: user, scopes: ['account_management'])

    User.any_instance.expects(:destroy).returns(true)
    delete admin_api_account_user_path(@buyer, format: :xml, id: @member.id), params: { access_token: token.value }
    assert_response :success

    user.role = 'admin'
    user.save!
    User.any_instance.expects(:destroy).returns(true)
    delete admin_api_account_user_path(@buyer, format: :xml, id: @member.id), params: { access_token: token.value }
    assert_response :success
  end

  test 'suspend/unsuspend (access_token)' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryBot.create(:access_token, owner: user, scopes: ['account_management'])

    User.any_instance.expects(:suspend!).returns(true)
    put suspend_admin_api_account_user_path(@buyer.id, id: @member.id, format: :xml), params: { username: 'alex', access_token: token.value }
    assert_response :success
    User.any_instance.expects(:unsuspend).returns(true)
    put unsuspend_admin_api_account_user_path(@buyer.id, id: @member.id, format: :xml), params: { username: 'alex', access_token: token.value }
    assert_response :success

    user.role = 'admin'
    user.save!
    User.any_instance.expects(:suspend!).returns(true)
    put suspend_admin_api_account_user_path(@buyer.id, id: @member.id, format: :xml), params: { username: 'alex', access_token: token.value }
    assert_response :success
    User.any_instance.expects(:unsuspend).returns(true)
    put unsuspend_admin_api_account_user_path(@buyer.id, id: @member.id, format: :xml), params: { username: 'alex', access_token: token.value }
    assert_response :success
  end

  # Provider key

  test 'buyer account not found' do
    other_provider = FactoryBot.create(:provider_account, domain: 'other.example.com')

    other_buyer = FactoryBot.create(:buyer_account, provider_account: other_provider)
    other_buyer.buy! other_provider.account_plans.first

    get admin_api_account_users_path(account_id: other_buyer.id, format: :xml), params: { provider_key: @provider.api_key }
    assert_xml_404
  end

  test 'index' do
    get admin_api_account_users_path(account_id: @buyer.id, format: :xml), params: { provider_key: @provider.api_key }

    assert_response :success
    assert_users @response.body, { account_id: @buyer.id }
  end

  #TODO: dry these roles tests
  test 'admins' do
    get admin_api_account_users_path(account_id: @buyer.id, format: :xml), params: { provider_key: @provider.api_key, role: 'admin' }

    assert_response :success
    assert_users @response.body, { account_id: @buyer.id, role: "admin" }
  end

  test 'members' do
    get admin_api_account_users_path(account_id: @buyer.id, format: :xml), params: { provider_key: @provider.api_key, role: 'member' }

    assert_response :success
    assert_users @response.body, { account_id: @buyer.id, role: "member" }
  end

  #TODO: dry these states tests
  test 'actives' do
    get admin_api_account_users_path(account_id: @buyer.id, format: :xml), params: { provider_key: @provider.api_key, state: 'active' }

    assert_response :success
    assert_users @response.body, { account_id: @buyer.id, state: "active" }
  end

  test 'pendings' do
    get admin_api_account_users_path(account_id: @buyer.id, format: :xml), params: { provider_key: @provider.api_key, state: 'pending' }

    assert_response :success
    assert_users @response.body, { account_id: @buyer.id, state: "pending" }
  end

  test 'suspendeds' do
    chuck = FactoryBot.create(:user, account: @buyer)
    chuck.activate!
    chuck.suspend!

    get admin_api_account_users_path(account_id: @buyer.id, format: :xml), params: { provider_key: @provider.api_key, state: 'suspended' }

    assert_response :success
    assert_users @response.body, {account_id: @buyer.id, state: "suspended"}
  end

  test 'invalid role' do
    get admin_api_account_users_path(account_id: @buyer.id, format: :xml), params: { provider_key: @provider.api_key, role: 'invalid' }

    assert_response :success

    assert_empty_users @response.body
  end

  pending_test 'index returns fields defined'

  test 'create defaults is pending member' do
    post admin_api_account_users_path(account_id: @buyer.id, format: :xml), params: { username: 'chuck', email: 'chuck@norris.us', provider_key: @provider.api_key }

    assert_response :success
    assert_user(@response.body,
                { account_id: @buyer.id,
                  role: "member",
                  state: "pending" })

    assert User.last.pending?
    assert User.last.member?
  end

  test "create sends no email" do
    assert_no_change :of => -> { ActionMailer::Base.deliveries.count } do
      post admin_api_account_users_path(account_id: @buyer.id, format: :xml), params: { username: 'chuck', email: 'chuck@norris.us', provider_key: @provider.api_key }
    end

    assert_response :success
  end

  test 'create does not creates admins nor active users' do
    post admin_api_account_users_path(account_id: @buyer.id, format: :xml), params: { username: 'chuck', role: "admin", email: 'chuck@norris.us', state: "active", provider_key: @provider.api_key }

    assert_response :success
    assert_user(@response.body,
                { account_id: @buyer.id,
                  role: "member",
                  state: "pending" })

    assert User.last.pending?
    assert User.last.member?
  end

  test 'create also sets user password' do
    post admin_api_account_users_path(account_id: @buyer.id, format: :xml), params: { username: 'chuck', email: 'chuck@norris.us', password: "posted-password", password_confirmation: "posted-password", provider_key: @provider.api_key }

    chuck = User.last
    assert chuck.authenticate("posted-password")
    assert_not_empty chuck.password_digest
  end

  test 'create with extra fields' do
    field_defined(@provider,
                  { :target => "User", "name" => "some_extra_field" })

    post admin_api_account_users_path(account_id: @buyer.id, format: :xml), params: { username: 'chuck', email: 'chuck@norris.us', some_extra_field: "extra value", provider_key: @provider.api_key }

    assert_response :success
    assert_user(@response.body,
                { account_id: @buyer.id,
                  extra_fields: { some_extra_field: "extra value" }})

    assert_equal User.find_by(username: "chuck").extra_fields["some_extra_field"], "extra value"
  end

  test 'create errors' do
    post admin_api_account_users_path(account_id: @buyer.id, format: :xml), params: { username: 'chuck', role: "admin", provider_key: @provider.api_key }

    assert_response :unprocessable_entity
    assert_xml_error @response.body, "Email should look like an email address"
  end

  test 'show' do
    get admin_api_account_user_path(account_id: @buyer.id, format: :xml, id: @member.id), params: { provider_key: @provider.api_key }

    assert_response :success
    assert_user @response.body, { account_id: @buyer.id, role: "member" }
  end

  test 'show user not found' do
    get admin_api_account_user_path(account_id: @buyer.id, format: :xml, id: 0), params: { provider_key: @provider.api_key }
    assert_xml_404
  end

  test 'show returns fields defined' do
    FactoryBot.create(:fields_definition, account: @provider, target: "User", name: "first_name")
    FactoryBot.create(:fields_definition, account: @provider, target: "User", name: "last_name")

    @member.update(first_name: "name non < > &", last_name: "last non < > &")

    get admin_api_account_user_path(account_id: @buyer.id, format: :xml, id: @member.id), params: { provider_key: @provider.api_key }

    assert_response :success
    assert_user(@response.body,
                { first_name: "name non &lt; &gt; &amp;",
                  last_name: "last non &lt; &gt; &amp;" })
  end

  test 'show does not return fields not defined' do
    @member.update(title: "title-not-returned")

    assert @member.defined_fields.map(&:name).exclude?(:title)

    get admin_api_account_user_path(account_id: @buyer.id, format: :xml, id: @member.id), params: { provider_key: @provider.api_key }

    assert_response :success
    xml = Nokogiri::XML::Document.parse(@response.body)
    assert xml.xpath('.//user/title').empty?
  end

  test 'update does not updates state nor role' do
    chuck = FactoryBot.create(:user, account: @buyer, role: "member")
    assert chuck.pending?
    assert chuck.member?

    put admin_api_account_user_path(account_id: @buyer.id, format: :xml, id: chuck.id), params: { username: 'chuck', role: "admin", state: "active", provider_key: @provider.api_key }

    assert_response :success
    assert_user(@response.body,
                { account_id: @buyer.id,
                  role: "member",
                  state: "pending" })

    chuck.reload
    assert chuck.pending?
    assert chuck.member?
  end

  test 'update also updates password' do
    chuck = FactoryBot.create(:user, account: @buyer, role: "member")
    assert_not_empty chuck.password_digest
    assert chuck.authenticate('superSecret1234#')

    put admin_api_account_user_path(account_id: @buyer.id,
                                         format: :xml, id: chuck.id,
                                         password: "updated-password",
                                         password_confirmation: "updated-password"),
        params: { provider_key: @provider.api_key }

    chuck.reload
    assert_response :success
    assert chuck.authenticate('updated-password')
  end

  test 'update also updates extra fields' do
    field_defined(@provider,
                  { :target => "User", "name" => "some_extra_field" })

    chuck = FactoryBot.create(:user, account: @buyer, role: "member")
    put admin_api_account_user_path(account_id: @buyer.id,
                                         format: :xml, id: chuck.id,
                                         some_extra_field: "extra value" ),
        params: { provider_key: @provider.api_key }

    assert_response :success
    assert_user(@response.body, { account_id: @buyer.id,
                  extra_fields: { some_extra_field: "extra value" }})

    chuck.reload
    assert_equal chuck.extra_fields["some_extra_field"], "extra value"
  end

  test 'update not found' do
    put admin_api_account_user_path(account_id: @buyer.id, format: :xml, id: 0), params: { provider_key: @provider.api_key }
    assert_xml_404
  end

  test 'destroy' do
    delete admin_api_account_user_path(account_id: @buyer.id, format: :xml, id: @member.id), params: { provider_key: @provider.api_key }

    assert_response :success
    assert_empty_xml @response.body

    delete admin_api_account_user_path(account_id: @buyer.id, format: :xml, id: @buyer.users.first.id), params: { provider_key: @provider.api_key }

    assert_response :forbidden, "last buyer's user should not be deleteable"
    assert_xml_error @response.body, 'last admin'
  end

  test 'destroy not found' do
    delete admin_api_account_user_path(account_id: @buyer.id, format: :xml, id: 0), params: { provider_key: @provider.api_key }
    assert_xml_404
  end

  test 'member' do
    chuck = FactoryBot.create(:user, account: @buyer)
    chuck.make_admin

    put member_admin_api_account_user_path(@buyer, chuck, provider_key: @provider.api_key, format: :xml)

    assert_response :success
    assert_user @response.body, { account_id: @buyer.id, role: "member" }

    chuck.reload
    assert chuck.member?
  end

  test 'admin' do
    chuck = FactoryBot.create(:user, account: @buyer)
    chuck.make_member

    put admin_admin_api_account_user_path(@buyer, chuck, provider_key: @provider.api_key, format: :xml)

    assert_response :success
    assert_user @response.body, { account_id: @buyer.id, role: "admin" }

    chuck.reload
    assert chuck.admin?
  end

  test 'suspend an active user' do
    chuck = FactoryBot.create(:user, account: @buyer)
    chuck.activate!

    put suspend_admin_api_account_user_path(@buyer, chuck, provider_key: @provider.api_key, format: :xml)

    assert_response :success
    assert_user @response.body, {account_id: @buyer.id, state: "suspended"}

    chuck.reload
    assert chuck.suspended?
  end

  test 'activate a pending user' do
    chuck = FactoryBot.create(:user, account: @buyer)

    put activate_admin_api_account_user_path(@buyer, chuck, provider_key: @provider.api_key, format: :xml)

    assert_response :success
    assert_user @response.body, {account_id: @buyer.id, state: "active"}

    chuck.reload
    assert chuck.active?
  end

  test 'shows error on failed user activation XML' do
    user = suspended_user
    put activate_admin_api_account_user_path(@buyer, user, provider_key: @provider.api_key, format: :xml)

    assert_response :unprocessable_entity

    assert_xml('/error') do |xml|
      assert_xml xml, './from', 'suspended'
      assert_xml xml, './event', 'activate'
      assert_xml xml, './user', Nokogiri::XML::Document.parse(user.to_xml)
    end

    assert user.reload.suspended?, 'user should be suspended'
  end

  test 'shows error on failed user activation JSON' do
    user = suspended_user

    put activate_admin_api_account_user_path(@buyer, user, provider_key: @provider.api_key, format: :json)

    assert_response :unprocessable_entity

    res = JSON.parse(@response.body)

    error = res.fetch('error')

    assert_equal({ 'from' => 'suspended', 'event' => 'activate',
                   'error' => 'State cannot transition via "activate"'
                 }, error.except('object'))

    assert_equal({'id' => user.id, 'state' => user.state },
                 error.fetch('object').fetch('user').slice('id', 'state'))

    assert user.reload.suspended?, 'user should be suspended'
  end

  test 'activate sends no email' do
    chuck = FactoryBot.create(:user, account: @buyer)
    assert_no_change :of => -> { ActionMailer::Base.deliveries.count } do
      put activate_admin_api_account_user_path(@buyer, chuck, provider_key: @provider.api_key, format: :xml)
    end
    assert_response :success
    chuck.reload
    assert chuck.active?
  end

  test 'unsuspend a suspended user' do
    chuck = suspended_user

    put unsuspend_admin_api_account_user_path(@buyer, chuck, provider_key: @provider.api_key, format: :xml)

    assert_response :success
    assert_user @response.body, { account_id: @buyer.id, state: "active" }

    chuck.reload
    assert chuck.active?
  end

  protected

  def active_user
    user = FactoryBot.create(:user, account: @buyer)
    user.activate!
    user
  end

  def suspended_user
    user = active_user
    user.suspend!
    user
  end
end
