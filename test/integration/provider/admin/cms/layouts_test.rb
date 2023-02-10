require 'test_helper'

class Provider::Admin::CMS::LayoutsTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)

    login_provider @provider

    host! @provider.external_admin_domain
  end

  def test_update
    layout = FactoryBot.create(:cms_layout, provider: @provider)
    params = { id: layout.id, cms_template: { draft: '<abc>0</abc>' }}

    (ENV['BRUTOFORCE'].present? ? 200 : 1).times do |i|
      params[:cms_template][:draft] = "<abc>#{i}</abc>"
      put provider_admin_cms_layout_path(params)
      assert_response :redirect
      assert_equal "<abc>#{i}</abc>", layout.reload.draft
    end
  end
end
