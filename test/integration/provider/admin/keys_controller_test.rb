require 'test_helper'

class Provider::Admin::KeysControllerTest < ActionDispatch::IntegrationTest
  def setup
    provider = FactoryBot.create(:provider_account)
    service = provider.default_service

    plan = FactoryBot.create(
      :application_plan,
      issuer: service
    )

    @application = FactoryBot.create(
      :cinstance,
      plan: plan,
      application_keys: FactoryBot.create_list(
        :application_key,
        2
      )
    )

    @key = @application.application_keys.first!

    @member_user = FactoryBot.create(
      :member,
      account: provider
    )
    @member_user.activate!

    @member_user_with_app_access = FactoryBot.create(
      :member,
      account: provider,
      admin_sections: ['partners']
    )
    @member_user_with_app_access.activate!
  end

  test 'GET new' do
    verb = :get
    path = new_provider_admin_application_key_path(
      application_id: @application.id
    )
    format = { format: :html }

    assert_only_qualified_members_have_access(verb, path, format)
  end

  test 'GET edit' do
    verb = :get
    path = edit_provider_admin_application_key_path(
      application_id: @application.id,
      id: @key.id
    )
    format = { format: :html }

    assert_only_qualified_members_have_access(verb, path, format)
  end

  test 'PATCH update' do
    verb = :patch
    path = provider_admin_application_key_path(
      application_id: @application.id,
      id: @key.id,
      'cinstance[user_key]': @key.value
    )
    format = { format: :js }

    assert_only_qualified_members_have_access(verb, path, format)
  end

  test 'POST create' do
    verb = :post
    path = provider_admin_application_keys_path(
      application_id: @application.id
    )
    format = { format: :js }

    assert_only_qualified_members_have_access(verb, path, format)
  end

  test 'DELETE destroy' do
    verb = :delete
    path = provider_admin_application_key_path(
      application_id: @application.id,
      id: @key.value
    )
    format = { format: :js }

    assert_only_qualified_members_have_access(verb, path, format)
  end

  test 'PUT regenerate' do
    verb = :put
    path = regenerate_provider_admin_application_key_path(
      application_id: @application.id,
      id: @key
    )
    format = { format: :js }

    assert_only_qualified_members_have_access(verb, path, format)
  end

  private

  def assert_only_qualified_members_have_access(verb, path, format)
    login! @member_user.account, user: @member_user
    public_send(verb, path, params: format)
    assert_response(
      :forbidden,
      "#{verb} #{path} should be forbidden for regular members"
    )

    login! @member_user_with_app_access.account, user: @member_user_with_app_access
    public_send(verb, path, params: format)
    assert_response(
      :success,
      "#{verb} #{path} should be authorized for members with permission"
    )
  end
end
