# frozen_string_literal: true

require 'test_helper'

class Buyers::UsersControllerIntegrationTest < ActionDispatch::IntegrationTest
  include FieldsDefinitionsHelpers

  def setup
    @provider = FactoryBot.create(:provider_account)
    login! provider
    @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
  end

  attr_reader :buyer, :provider

  test '#index renders the display name of all users' do
    FactoryBot.create(:member, account: buyer)

    get admin_buyers_account_users_path(account_id: buyer.reload.id)

    page = Nokogiri::HTML4::Document.parse(response.body)
    expected_display_names = buyer.users.map { |u| u.decorate.display_name }
    assert_same_elements expected_display_names, page.xpath('//tbody/tr/td[1]/a').map(&:text)
  end

  test '#show & #edit render the display_name of the user' do
    user = buyer.admin_user

    [
      admin_buyers_account_user_path(account_id: buyer.id, id: user.id),
      edit_admin_buyers_account_user_path(account_id: buyer.id, id: user.id)
    ].each do |route|
      get route

      page = Nokogiri::HTML4::Document.parse(response.body)
      assert_includes page.xpath('//section[contains(@class, "pf-c-page__main-section")]//h1').text, user.decorate.display_name
    end
  end

  test '#destroy' do
    destroyable_user = FactoryBot.create(:member, account: buyer)
    non_destroyable_user = buyer.admin_user

    delete admin_buyers_account_user_path(account_id: buyer.id, id: destroyable_user.id)
    assert_not User.exists?(destroyable_user.id)
    assert_equal 'User was successfully deleted', flash[:success]

    delete admin_buyers_account_user_path(account_id: buyer.id, id: non_destroyable_user.id)
    assert User.exists?(non_destroyable_user.id)
    assert_equal 'User could not be deleted', flash[:danger]
  end

  test '#update all attributes' do
    FactoryBot.create(:fields_definition, account: provider, target: 'User', name: 'country')
    user = FactoryBot.create(:member, account: buyer)

    put admin_buyers_account_user_path(account_id: buyer.id, id: user.id), params: {
      user: {
        role: 'admin',
        username: 'updatedusername',
        email: 'newemail@example.org',
        extra_fields: {
          country: 'Japan'
        }
      }
    }

    assert user.reload.admin?
    assert_equal 'updatedusername', user.username
    assert_equal 'newemail@example.org', user.email
    assert_equal 'Japan', user.field_value('country')
  end

  test 'only update optional fields that are enabled through fields definitions' do
    field_defined(provider, { target: 'User', name: 'first_name' })
    field_defined(provider, { target: 'User', name: 'last_name' })
    provider.reload
    user = FactoryBot.create(:member, account: buyer)
    assert_same_elements %w[username email first_name last_name], user.defined_fields_names

    optional_fields = {
      title: 'Ms.', first_name: 'fn', last_name: 'ln', job_role: 'manager'
    }

    optional_fields.each_key do |field|
      assert_nil user.public_send(field), "Field '#{field}' should not be set"
    end

    put admin_buyers_account_user_path(account_id: buyer.id, id: user.id), params: { user: optional_fields }

    user.reload

    assert_equal 'fn', user.first_name
    assert_equal 'ln', user.last_name
    assert_nil user.job_role
    assert_nil user.title
  end

  test "#activate" do
    user = FactoryBot.create(:pending_user, account: buyer)
    assert_not user.active?

    post activate_admin_buyers_account_user_path(account_id: buyer.id, id: user.id)
    follow_redirect!

    assert_response :ok
    assert user.reload.active?
  end

  test "update password" do
    user = buyer.admin_user
    new_password = SecureRandom.hex(8)
    assert_not user.authenticated?(new_password)

    put admin_buyers_account_user_path(account_id: buyer.id, id: user.id), params: {
      user: {
        password: new_password,
        password_confirmation: new_password
      }
    }

    user.reload
    assert user.reload.authenticated?(new_password)
  end

  test "do not update password in does not match password confirmation" do
    user = buyer.admin_user
    new_password = SecureRandom.hex(8)
    assert_not user.authenticated?(new_password)

    put admin_buyers_account_user_path(account_id: buyer.id, id: user.id), params: {
      user: {
        password: new_password,
        password_confirmation: new_password.reverse
      }
    }

    assert_not user.reload.authenticated?(new_password)

    page = Nokogiri::HTML::Document.parse(response.body)
    password_confirmation_error = page.at_xpath("//input[@id='user_password_confirmation']/following-sibling::p[@class='inline-errors']")
    assert password_confirmation_error
    assert_equal "doesn't match Password", password_confirmation_error.text
  end

  test "update user role" do
    member = FactoryBot.create(:member, account: buyer)
    assert member.member?

    put admin_buyers_account_user_path(account_id: buyer.id, id: member.id), params: {
      user: {
        role: "admin"
      }
    }

    assert member.reload.admin?
  end

  test "suspend and unsuspend user" do
    user = buyer.admin_user
    assert user.active?

    post suspend_admin_buyers_account_user_path(buyer, user)
    assert user.reload.suspended?

    post unsuspend_admin_buyers_account_user_path(buyer, user)
    assert user.reload.active?
  end
end
