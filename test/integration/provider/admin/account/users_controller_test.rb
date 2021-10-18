# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::Account::UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider    = FactoryBot.create :provider_account
    @default_ids = [:partners]
    @user        = FactoryBot.create :simple_user, account: @provider, member_permission_ids: @default_ids

    login! @provider
  end

  attr_reader :provider

  test 'index responds with a table with all the display_name of the users as the first column' do
    get provider_admin_account_users_path

    page = Nokogiri::HTML::Document.parse(response.body)
    expected_display_names = provider.reload.users.map { |u| u.decorate.display_name }
    assert_same_elements expected_display_names, page.xpath('//tbody/tr/td[1]/a').map(&:text)
  end

  test 'index displays the permission groups of each user' do
    FactoryBot.create(:member, account: provider)

    get provider_admin_account_users_path

    page = Nokogiri::HTML::Document.parse(response.body)
    expected_admin_sections = [
      'Unlimited Access',                  # admin
      'Developer accounts, Applications',  # @user
      '-'                                  # member w/ no permission group
    ]
    assert_same_elements expected_admin_sections, page.xpath('//tbody/tr/td[4]').map(&:text)
  end

  def test_update_blank_member_permission_ids
    assert_equal @default_ids, @user.admin_sections.to_a

    put provider_admin_account_user_path(@user), params: { user: {member_permission_ids: ['']} }

    @user.reload

    assert_equal [], @user.admin_sections.to_a
  end

  def test_update_no_member_permission_ids
    assert_equal @default_ids, @user.admin_sections.to_a

    put provider_admin_account_user_path(@user), params: { user: {} }

    @user.reload

    assert_equal @default_ids, @user.admin_sections.to_a
  end

  test 'admin deletes another admin' do
    user = FactoryBot.create(:admin, account: provider)

    delete provider_admin_account_user_path(user.id)

    assert_raises(ActiveRecord::RecordNotFound) { user.reload }
  end

  test 'admin cannot delete himself' do
    user = provider.admin_users.first!

    delete provider_admin_account_user_path(user.id)

    assert user.reload
  end

  test 'admin changes role of another admin' do
    user = FactoryBot.create(:admin, account: provider)

    put provider_admin_account_user_path(user), params: { user: {role: 'member'} }

    assert user.reload.member?
  end

  test 'admin cannot edit his own role' do
    user = provider.admin_users.first!

    put provider_admin_account_user_path(user), params: { user: {role: 'member'} }

    assert user.reload.admin?
  end
end
