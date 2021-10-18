# frozen_string_literal: true

require 'test_helper'

class Buyers::UsersControllerIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    login! provider
    @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
  end

  attr_reader :buyer, :provider

  test '#index renders the display name of all users' do
    FactoryBot.create(:member, account: buyer)

    get admin_buyers_account_users_path(account_id: buyer.reload.id)

    page = Nokogiri::HTML::Document.parse(response.body)
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

      page = Nokogiri::HTML::Document.parse(response.body)
      assert_includes page.xpath('//main/h2').text, user.decorate.display_name
    end
  end

  test '#destroy' do
    destroyable_user = FactoryBot.create(:member, account: buyer)
    non_destroyable_user = buyer.admin_user

    delete admin_buyers_account_user_path(account_id: buyer.id, id: destroyable_user.id)
    refute User.exists?(destroyable_user.id)
    assert_equal 'User was successfully deleted.', flash[:notice]

    delete admin_buyers_account_user_path(account_id: buyer.id, id: non_destroyable_user.id)
    assert User.exists?(non_destroyable_user.id)
    assert_equal 'User could not be deleted.', flash[:error]
  end

  test '#update all attributes' do
    FactoryBot.create(:fields_definition, account: provider, target: 'User', name: 'country')
    user = FactoryBot.create(:member, account: buyer)

    put admin_buyers_account_user_path(account_id: buyer.id, id: user.id), params: { user: {
        role: 'admin',
        username: 'updatedusername',
        email: 'newemail@example.org',
        country: 'Japan'
      } }

    assert user.reload.admin?
    assert_equal 'updatedusername', user.username
    assert_equal 'newemail@example.org', user.email
    assert_equal 'Japan', user.field_value('country')
  end
end
