require 'test_helper'

class ApiDocs::ProviderUserDataTest < ActiveSupport::TestCase
  def setup
    account = FactoryBot.create(:simple_provider)
    @admin = FactoryBot.build_stubbed(:simple_user, role: :admin, account: account)
  end

  def test_access_tokens_field_with_hint
    data = ApiDocs::ProviderUserData.new(@admin).as_json[:results]
    assert_equal [{ name: 'First create an access token in the Personal Settings section.',
                   value: '' }], data[:access_token]
  end

  def test_service_tokens
    data = ApiDocs::ProviderUserData.new(@admin).as_json[:results]
    assert_equal [{ name: "You don't have access to any services, contact an administrator of this account.",
                    value: '' }], data[:service_tokens]

    service = FactoryBot.create(:simple_service, account: @admin.account)
    service_other = FactoryBot.create(:simple_service, account: @admin.account)
    _service_without_token = FactoryBot.create(:simple_service, account: @admin.account)
    @admin.account.reload # ensure that @admin.account.service_ids returns the updated list of services

    # Resets all service_tokens
    ServiceToken.where(service_id: [service, service_other, _service_without_token]).delete_all
    service.service_tokens.create!(value: 'Foo')
    service_other.service_tokens.create!(value: 'Bar')

    admin_data = ApiDocs::ProviderUserData.new(@admin).as_json[:results]
    assert_same_elements [{ name: service.name, value: 'Foo' }, { name: service_other.name, value: 'Bar' }], admin_data[:service_tokens]

    member = FactoryBot.create(:simple_user, account: @admin.account, member_permission_ids: [:plans], member_permission_service_ids: [service.id])

    data1 = ApiDocs::ProviderUserData.new(member).as_json[:results]
    assert_equal [{ name: service.name, value: 'Foo' }], data1[:service_tokens]
  end

  class MemberPermissions < ActiveSupport::TestCase
    def setup
      account = FactoryBot.create(:simple_provider)
      @admin = FactoryBot.build_stubbed(:simple_user, role: :admin, account: account)

      @authorized_service = FactoryBot.create(:simple_service, account: @admin.account)
      @unauthorized_service = FactoryBot.create(:simple_service, account: @admin.account)

      authorized_application_plan = FactoryBot.create(:application_plan, issuer: @authorized_service)
      unauthorized_application_plan = FactoryBot.create(:application_plan, issuer: @unauthorized_service)

      @authorized_cinstance = FactoryBot.create(:simple_cinstance, plan: authorized_application_plan, state: 'live')
      @unauthorized_cinstance = FactoryBot.create(:simple_cinstance, plan: unauthorized_application_plan, state: 'live')
    end

    test 'admin users can see all applications' do
      apps = ApiDocs::ProviderUserData.new(@admin).apps.to_a
      assert_same_elements [@authorized_cinstance, @unauthorized_cinstance], apps
    end

    test 'member users can only see applications of authorized services' do
      member = FactoryBot.create(:simple_user, account: @admin.account, member_permission_ids: [:plans], member_permission_service_ids: [@authorized_service.id])

      apps = ApiDocs::ProviderUserData.new(member).apps.to_a
      assert_includes apps, @authorized_cinstance
      assert_not_includes apps, @unauthorized_cinstance
    end

    test 'member users see no application if no service id is authorized' do
      member = FactoryBot.create(:simple_user, account: @admin.account)
      FactoryBot.create(:member_permission, user: member, admin_section: :services, service_ids: [])
      assert_empty ApiDocs::ProviderUserData.new(member).apps.to_a
    end

    test 'member users with no permissions cannot see applications' do
      member = FactoryBot.create(:simple_user, account: @admin.account)
      apps = ApiDocs::ProviderUserData.new(member).apps.to_a
      assert_empty apps
    end

    test 'member users with access to all services see all applications' do
      member = FactoryBot.create(:simple_user, account: @admin.account, allowed_sections: ['plans'], allowed_service_ids: nil)
      apps = ApiDocs::ProviderUserData.new(member).apps.to_a
      assert_same_elements [@authorized_cinstance, @unauthorized_cinstance], apps
    end
  end
end
