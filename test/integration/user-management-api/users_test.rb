# frozen_string_literal: true

require 'test_helper'

class Admin::Api::UsersTest < ActionDispatch::IntegrationTest
  include FieldsDefinitionsHelpers

  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')

    @master = @provider.provider_account
    field_defined(@master, name: 'username')
    field_defined(@master, name: 'email')

    @member = FactoryBot.create(:user, account: @provider, role: 'member', admin_sections: ['partners'])

    host! @provider.external_admin_domain
  end

  # ACCESS TOKEN

  test 'index with access token as a member' do
    token = FactoryBot.create(:access_token, owner: @member, scopes: ['account_management'])

    get admin_api_users_path(format: :xml), params: { access_token: token.value }

    assert_response :forbidden
  end

  test 'index with access token as an admin' do
    token = FactoryBot.create(:access_token, owner: admin, scopes: ['account_management'])

    Settings::Switch.any_instance.stubs(:allowed?).returns(false)
    get admin_api_users_path(format: :xml), params: { access_token: token.value }
    assert_response :forbidden

    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    get admin_api_users_path(format: :xml), params: { access_token: token.value }
    assert_response :success
  end

  test 'index do not return the impersonation admin user' do
    token = FactoryBot.create(:access_token, owner: admin, scopes: ['account_management'])
    impersonation_admin = Signup::ImpersonationAdminBuilder.build(account: @provider)
    impersonation_admin.save!

    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    get admin_api_users_path(format: :xml), params: { access_token: token.value }
    assert_response :success
    refute_xpath ".//username", /impersonation_admin/
  end

  test 'show with access token as a member' do
    token = FactoryBot.create(:access_token, owner: @member, scopes: ['account_management'])

    # member's opening his page
    get admin_api_user_path(format: :xml, id: @member.id), params: { access_token: token.value }
    assert_response :success

    # member's opening admin's page
    get admin_api_user_path(format: :xml, id: admin.id), params: { access_token: token.value }
    assert_response :forbidden
  end

  test 'show with access token as an admin' do
    token = FactoryBot.create(:access_token, owner: admin, scopes: ['account_management'])

    get admin_api_user_path(format: :xml, id: @member.id), params: { access_token: token.value }

    assert_response :success
  end

  test 'create with access token as an admin' do
    token = FactoryBot.create(:access_token, owner: admin, scopes: ['account_management'])

    Settings::Switch.any_instance.stubs(:allowed?).returns(false)
    post admin_api_users_path(format: :xml), params: { username: 'aaa', email: 'aaa@aaa.hu', access_token: token.value }
    assert_response :forbidden

    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    post admin_api_users_path(format: :xml), params: { username: 'aaa', email: 'aaa@aaa.hu', access_token: token.value }
    assert_response :success
  end

  test 'update with access token as a member' do
    token = FactoryBot.create(:access_token, owner: @member, scopes: ['account_management'])

    put admin_api_user_path(format: :xml, id: @member.id, access_token: token.value)
    assert_response :success

    put admin_api_user_path(format: :xml, id: admin.id, access_token: token.value)
    assert_response :forbidden
  end

  test 'update with access token as an admin' do
    token = FactoryBot.create(:access_token, owner: admin, scopes: ['account_management'])

    put admin_api_user_path(format: :xml, id: @member.id, access_token: token.value)

    assert_response :success
  end

  test 'destroy with access token as a member' do
    token = FactoryBot.create(:access_token, owner: @member, scopes: ['account_management'])

    delete admin_api_user_path(format: :xml, id: admin.id, access_token: token.value)

    assert_response :forbidden
  end

  test 'destroy with access token as an admin' do
    token = FactoryBot.create(:access_token, owner: admin, scopes: ['account_management'])

    delete admin_api_user_path(format: :xml, id: @member.id, access_token: token.value)

    assert_response :success
  end

  test 'admin/update_role with access token as a member' do
    token = FactoryBot.create(:access_token, owner: @member, scopes: ['account_management'])

    put admin_api_user_path(format: :xml, id: admin.id, access_token: token.value)

    assert_response :forbidden
  end

  test 'admin/update_role with access token as an admin' do
    token = FactoryBot.create(:access_token, owner: admin, scopes: ['account_management'])

    put admin_api_user_path(format: :xml, id: @member.id, access_token: token.value)

    assert_response :success
  end

  test 'set group permissions as an admin' do
    token = FactoryBot.create(:access_token, owner: admin, scopes: ['account_management'])
    service = @provider.services.default

    put admin_api_user_path(format: :xml, id: @member.id, access_token: token.value), params: { member_permission_service_ids: [service.id], member_permission_ids: %w[monitoring services] }

    assert_response :success

    assert @member.reload
    assert_equal [service.id], @member.member_permission_service_ids
    assert_equal Set[ :services, :monitoring ], @member.admin_sections
  end

  test 'set group permissions as a member' do
    token = FactoryBot.create(:access_token, owner: @member, scopes: ['account_management'])
    service = @provider.services.default
    admin_sections = @member.admin_sections

    put admin_api_user_path(format: :xml, id: @member.id, access_token: token.value), params: { member_permission_service_ids: [service.id], member_permission_ids: %w[monitoring] }

    assert_response :success

    # the permissions have not changed - the same as original
    assert @member.reload
    assert_nil @member.member_permission_service_ids
    assert_equal admin_sections, @member.admin_sections
  end

  test 'suspend/unsuspend with access token as a member' do
    token = FactoryBot.create(:access_token, owner: @member, scopes: ['account_management'])

    admin.activate!

    put suspend_admin_api_user_path(format: :xml, id: admin.id, access_token: token.value)
    assert_response :forbidden

    put unsuspend_admin_api_user_path(format: :xml, id: admin.id, access_token: token.value)
    assert_response :forbidden
  end

  test 'suspend/unsuspend with access token as an admin' do
    token = FactoryBot.create(:access_token, owner: admin, scopes: ['account_management'])

    @member.activate!

    put suspend_admin_api_user_path(format: :xml, id: @member.id, access_token: token.value)
    assert_response :success

    put unsuspend_admin_api_user_path(format: :xml, id: @member.id, access_token: token.value)
    assert_response :success
  end

  # PROVIDER ID

  #TODO: explicitly test the extra fields
  test 'index' do
    get admin_api_users_path(format: :xml), params: { provider_key: @provider.api_key }

    assert_response :success
    assert_users @response.body, { account_id: @provider.id }
  end

  #TODO: dry these roles tests
  test 'admins' do
    get admin_api_users_path(format: :xml), params: { provider_key: @provider.api_key, role: 'admin' }

    assert_response :success
    assert_users @response.body, { account_id: @provider.id, role: "admin" }
  end

  test 'members' do
    get admin_api_users_path(format: :xml), params: { provider_key: @provider.api_key, role: 'member' }

    assert_response :success
    assert_users @response.body, { account_id: @provider.id, role: "member" }
  end

  #TODO: dry these states tests
  test 'actives' do
    get admin_api_users_path(format: :xml), params: { provider_key: @provider.api_key, state: 'active' }

    assert_response :success
    assert_users @response.body, { account_id: @provider.id, state: "active" }
  end

  test 'pendings' do
    get admin_api_users_path(format: :xml), params: { provider_key: @provider.api_key, state: 'pending' }

    assert_response :success
    assert_users @response.body, { account_id: @provider.id, state: "pending" }
  end

  test 'suspendeds' do
    chuck = FactoryBot.create(:user, account: @provider)
    chuck.activate!
    chuck.suspend!

    get admin_api_users_path(format: :xml), params: { provider_key: @provider.api_key, state: 'suspended' }

    assert_response :success
    assert_users @response.body, { account_id: @provider.id, state: "suspended"}
  end

  test 'invalid role' do
    get admin_api_users_path(format: :xml), params: { provider_key: @provider.api_key, role: 'invalid' }

    assert_response :success

    assert_empty_users @response.body
  end

  pending_test 'index returns fields defined'

  test 'create defaults is pending member' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    post admin_api_users_path(format: :xml), params: { username: 'chuck', email: 'chuck@norris.us', provider_key: @provider.api_key }

    assert_response :success
    assert_user(@response.body, { account_id: @provider.id, role: "member", state: "pending" })

    assert User.last.pending?
    assert User.last.member?
  end

  test 'create with extra fields' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    field_defined(@master, { target: 'User', name: 'some_extra_field' })

    post admin_api_users_path(format: :xml), params: { username: 'chuck', email: 'chuck@norris.us', some_extra_field: 'extra value', provider_key: @provider.api_key }

    assert_response :success

    assert_user(@response.body, { account_id: @provider.id, extra_fields: { some_extra_field: 'extra value' }})

    assert_equal User.last.extra_fields['some_extra_field'], 'extra value'
  end

  test "create sends no email" do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    assert_no_change :of => -> { ActionMailer::Base.deliveries.count } do
      post admin_api_users_path(format: :xml), params: { username: 'chuck', email: 'chuck@norris.us', provider_key: @provider.api_key }
    end

    assert_response :success
  end

  test "create with cas_identifier" do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    post admin_api_users_path(format: :xml), params: { username: 'luis', email: 'luis@norris.us', cas_identifier: 'luis', provider_key: @provider.api_key }

    assert_response :success
    assert_user body, { cas_identifier: 'luis' }
  end

  test 'create does not creates admins nor active users' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    post admin_api_users_path(format: :xml), params: { username: 'chuck', role: 'admin', email: 'chuck@norris.us', state: 'active', provider_key: @provider.api_key }

    assert_response :success
    assert_user(@response.body, { account_id: @provider.id, role: 'member', state: 'pending' })

    assert User.last.pending?
    assert User.last.member?
  end

  test 'create also sets user password' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    post admin_api_users_path(format: :xml), params: { username: 'chuck',
                                             email: 'chuck@norris.us',
                                             password: 'posted-password',
                                             password_confirmation: 'posted-password',
                                             provider_key: @provider.api_key }

    chuck = User.last
    assert chuck.authenticated?('posted-password')
  end

  test 'create errors' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    post admin_api_users_path(format: :xml), params: { username: 'chuck', role: "admin", provider_key: @provider.api_key }

    assert_response :unprocessable_entity
    assert_xml_error @response.body, "Email should look like an email address"
  end

  test "create forbidden if multiple_users is not allowed" do
    assert_no_change :of => -> { ActionMailer::Base.deliveries.count } do
      post admin_api_users_path(format: :xml), params: { username: 'chuck', email: 'chuck@norris.us', provider_key: @provider.api_key }
    end

    assert_response :forbidden
  end

  test 'show' do
    get admin_api_user_path(format: :xml, id: @member.id), params: { provider_key: @provider.api_key }

    assert_response :success
    assert_user(@response.body, { account_id: @provider.id,
                                  role: 'member',
                                  created_at: @member.created_at.xmlschema,
                                  updated_at: @member.updated_at.xmlschema })
  end

  test '3scale not found' do
    impersonation_admin = Signup::ImpersonationAdminBuilder.build(account: @provider)
    impersonation_admin.save!

    get admin_api_user_path(format: :xml, id: impersonation_admin.id), params: { provider_key: @provider.api_key }

    assert_response :not_found
    assert_empty_xml @response.body
  end

  test 'show with cas identifier' do
    cas_user = FactoryBot.create(:user, account: @provider, role: 'member', cas_identifier: 'xxx-enterprise')

    get admin_api_user_path(format: :xml, id: cas_user.id), params: { provider_key: @provider.api_key }

    assert_response :success
    assert_user body, cas_identifier: 'xxx-enterprise'
  end

  test 'show returns extra fields escaped' do
    field_defined(@master, { target: 'User', name: 'some_extra_field' })

    @member.reload
    @member.extra_fields = { some_extra_field: '< > &' }

    @member.save

    get admin_api_user_path(format: :xml, id: @member.id), params: { provider_key: @provider.api_key }

    assert_response :success
    assert_user(@response.body, extra_fields: { some_extra_field: '&lt; &gt; &amp;' })
  end

  test 'show user not found' do
    get admin_api_user_path(format: :xml, id: 0), params: { provider_key: @provider.api_key }

    assert_response :not_found
    assert_empty_xml @response.body
  end

  test 'update also updates extra fields' do
    field_defined(@master, { target: 'User', name: 'some_extra_field' })

    chuck = FactoryBot.create(:user, account: @provider, role: 'member')
    put admin_api_user_path(format: :xml, id: chuck.id, some_extra_field: 'extra value'), params: { provider_key: @provider.api_key }

    assert_response :success
    assert_user(@response.body, { account_id: @provider.id, extra_fields: { some_extra_field: 'extra value' }})

    chuck.reload
    assert_equal chuck.extra_fields['some_extra_field'], 'extra value'
  end

  test 'update also updates password' do
    chuck = FactoryBot.create(:user, account: @provider, role: 'member')
    assert chuck.authenticated?('superSecret1234#')

    put admin_api_user_path(format: :xml, id: chuck.id, password: "updated-password", password_confirmation: "updated-password"), params: { provider_key: @provider.api_key }

    chuck.reload
    assert_response :success
    assert chuck.authenticated?('updated-password')
  end

  test 'update with weak password rejected when strong passwords enabled' do
    chuck = FactoryBot.create(:user, account: @provider, role: 'member')

    put admin_api_user_path(format: :xml, id: chuck.id, password: "weakpwd", password_confirmation: "weakpwd"), params: { provider_key: @provider.api_key }

    assert_response :unprocessable_entity
    assert_match "is too short (minimum is 15 characters)", response.body
  end

  test 'update with strong password accepted when strong passwords enabled' do
    chuck = FactoryBot.create(:user, account: @provider, role: 'member')

    put admin_api_user_path(format: :xml, id: chuck.id, password: "superSecret1234#", password_confirmation: "superSecret1234#"), params: { provider_key: @provider.api_key }

    chuck.reload
    assert_response :success
    assert chuck.authenticated?('superSecret1234#')
  end

  test 'update does not updates state nor role' do
    chuck = FactoryBot.create(:user, account: @provider, role: 'member')
    assert chuck.pending?
    assert chuck.member?

    put admin_api_user_path(format: :xml, id: chuck.id), params: { username: 'chuck', role: 'admin', state: 'active', provider_key: @provider.api_key }

    assert_response :success
    assert_user(@response.body, { account_id: @provider.id, role: 'member', state: 'pending' })

    chuck.reload
    assert chuck.pending?
    assert chuck.member?
  end

  test 'update not found' do
    put admin_api_user_path(format: :xml, id: 0), params: { provider_key: @provider.api_key }

    assert_response :not_found
    assert_empty_xml @response.body
  end

  test 'destroy' do
    delete admin_api_user_path(format: :xml, id: @member.id), params: { provider_key: @provider.api_key }

    assert_response :success
    assert_empty_xml @response.body
  end

  test 'destroy not found' do
    delete admin_api_user_path(format: :xml, id: 0), params: { provider_key: @provider.api_key }

    assert_response :not_found
    assert_empty_xml @response.body
  end

  test 'member' do
    chuck = FactoryBot.create(:user, account: @provider)
    chuck.make_admin

    put member_admin_api_user_path(chuck, format: :xml, provider_key: @provider.api_key )

    assert_response :success
    assert_user @response.body, { account_id: @provider.id, role: 'member' }

    chuck.reload
    assert chuck.member?
  end

  test 'admin' do
    chuck = FactoryBot.create(:user, account: @provider)
    chuck.make_member

    put admin_admin_api_user_path(chuck, format: :xml, provider_key: @provider.api_key )

    assert_response :success
    assert_user @response.body, { account_id: @provider.id, role: "admin" }

    chuck.reload
    assert chuck.admin?
  end

  test 'suspend an active user' do
    chuck = FactoryBot.create(:user, account: @provider)
    chuck.activate!

    put suspend_admin_api_user_path(chuck, format: :xml, provider_key: @provider.api_key )

    assert_response :success
    assert_user @response.body, { account_id: @provider.id, state: 'suspended'}

    chuck.reload
    assert chuck.suspended?
  end

  test 'activate a pending user' do
    chuck = FactoryBot.create(:user, account: @provider)

    put activate_admin_api_user_path(chuck, format: :xml, provider_key: @provider.api_key )

    assert_response :success
    assert_user @response.body, { account_id: @provider.id, state: 'active'}

    chuck.reload
    assert chuck.active?
  end

  test 'activate sends no email' do
    chuck = FactoryBot.create(:user, account: @provider)
    assert_no_change :of => -> { ActionMailer::Base.deliveries.count } do
      put activate_admin_api_user_path(chuck, format: :xml, provider_key: @provider.api_key )
    end
    assert_response :success
    chuck.reload
    assert chuck.active?
  end

  test 'unsuspend a suspended user' do
    chuck = FactoryBot.create(:user, account: @provider)
    chuck.activate!
    chuck.suspend!

    put unsuspend_admin_api_user_path(chuck, format: :xml, provider_key: @provider.api_key )

    assert_response :success
    assert_user @response.body, { account_id: @provider.id, state: 'active' }

    chuck.reload
    assert chuck.active?
  end

  private

  def admin
    @admin ||= FactoryBot.create :simple_user, account: @provider, role: 'admin'
  end
end
