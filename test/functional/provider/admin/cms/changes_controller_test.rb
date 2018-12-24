require 'test_helper'

class Provider::Admin::CMS::ChangesControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    host! @provider.admin_domain
    login_as FactoryBot.create(:admin, :account => @provider)
  end

  # regression test - remove when DB is clean (see app/models/account/provider_methods.rb)
  test "index should not be broken by presence of legacy CMS::LegalTerm" do
    layout = FactoryBot.create(:cms_layout, provider: @provider, draft: 'XXX')
    layout.update_column(:type, 'CMS::LegalTerm')

    get 'index'

    assert_response :success
  end
end
