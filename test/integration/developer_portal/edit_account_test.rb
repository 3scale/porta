require 'test_helper'

class DeveloperPortal::EditAccountTest < ActionDispatch::IntegrationTest
  include DeveloperPortal::Engine.routes.url_helpers

  def setup
    @provider = FactoryBot.create(:simple_provider)
    @buyer    = FactoryBot.create(:buyer_account, provider_account: @provider, org_name: 'ontheroad')

    login_buyer @buyer

    host! @provider.domain
  end

  def test_update
    assert_not_equal 'west', @buyer.org_name
    put admin_account_path(account: { business: 'alaska', org_name: 'west' })
    assert_response :redirect
    @buyer.reload
    assert_equal 'west', @buyer.org_name
  end

  def test_show_form
    FactoryBot.create(:fields_definition, account: @provider, target: 'Account', name: 'country')

    get edit_admin_account_path
    assert_response :success
    assert_select '[name=?]', 'account[country_id]'
  end
end
