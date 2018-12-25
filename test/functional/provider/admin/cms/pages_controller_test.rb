require 'test_helper'

class Provider::Admin::CMS::PagesControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:simple_provider)
    host! @provider.admin_domain
    login_as FactoryBot.create(:admin, :account => @provider)
  end

  # regression test - it was possible somehow possible to delete a builtin page
  test "deleting builtin page returns 404" do
    root = FactoryBot.create(:root_cms_section, :provider => @provider)
    page = FactoryBot.create(:cms_builtin_page, :provider => @provider, :section => root)

    delete :destroy, :id => page.id

    assert_response :not_found
  end
end
