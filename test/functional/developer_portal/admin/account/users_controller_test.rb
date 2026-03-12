# frozen_string_literal: true

require "test_helper"

class DeveloperPortal::Admin::Account::UsersControllerTest < DeveloperPortal::ActionController::TestCase
  include FieldsDefinitionsHelpers

  def setup
    super
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @admin_user = @buyer.admins.first
    @member_user = FactoryBot.create(:active_user, account: @buyer)

    host! @provider.external_domain
    login_as @admin_user
  end

  test "index shows users list" do
    get :index
    assert_response :success
  end

  test "edit shows user form" do
    get :edit, params: { id: @member_user.id }
    assert_response :success
  end

  test "update with valid params redirects to users list" do
    put :update, params: {
      id: @member_user.id,
      user: { username: "new_username", email: "newemail@example.com" }
    }

    assert_redirected_to admin_account_users_path
    assert_equal "User was successfully updated.", flash[:notice]

    @member_user.reload
    assert_equal "new_username", @member_user.username
    assert_equal "newemail@example.com", @member_user.email
  end

  test "update with invalid params renders edit" do
    put :update, params: {
      id: @member_user.id,
      user: { email: "invalid-email" }
    }

    assert_response :success
    assert_template :edit
  end

  test "update can change role when authorized" do
    put :update, params: {
      id: @member_user.id,
      user: { role: "admin" }
    }

    @member_user.reload
    assert_equal :admin, @member_user.role
  end

  test "member cannot change its own role" do
    login_as @member_user

    put :update, params: {
      id: @member_user.id,
      user: { role: "admin" }
    }

    @member_user.reload
    assert_equal :member, @member_user.role
  end

  test "update custom fields that are not read-only" do
    field_defined(@provider, { target: "User", name: "custom_field" })
    field_defined(@provider, { target: "User", name: "readonly_field", read_only: true })
    @member_user.reload

    @member_user.update("custom_field" => "custom", "readonly_field" => "readonly")

    put :update, params: {
      id: @member_user.id,
      user: { custom_field: "new custom", readonly_field: "new readonly" }
    }

    @member_user.reload
    assert_equal "new custom", @member_user.extra_fields["custom_field"]
    assert_equal "readonly", @member_user.extra_fields["readonly_field"]
  end

  test "destroy removes user" do
    user_to_delete = FactoryBot.create(:active_user, account: @buyer)

    assert_difference "@buyer.users.count", -1 do
      delete :destroy, params: { id: user_to_delete.id }
    end

    assert_redirected_to admin_account_users_path
  end
end
