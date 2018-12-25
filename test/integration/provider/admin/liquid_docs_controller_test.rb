# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::LiquidDocsControllerTest < ActionDispatch::IntegrationTest
  def setup
    login! FactoryBot.create(:provider_account)
  end

  test 'show activates the proper menus' do
    get provider_admin_liquid_docs_path
    active_menus = assigns(:active_menus)
    assert_equal({main_menu: :audience, submenu: :cms, sidebar: :liquid_reference, topmenu: :dashboard}, active_menus)
  end
end
