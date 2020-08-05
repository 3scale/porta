# frozen_string_literal: true

require 'test_helper'

class Buyers::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    provider = FactoryBot.create(:provider_account)
    login! provider
    @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
  end

  attr_reader :buyer

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
end
