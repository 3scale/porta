require 'test_helper'

class Provider::Admin::Cms::LayoutsTest < ActionDispatch::IntegrationTest
  disable_transactional_fixtures!

  def setup
    @provider = FactoryGirl.create(:provider_account)

    login_provider @provider

    host! @provider.admin_domain
  end

  def test_update
    layout = FactoryGirl.create(:cms_layout, provider: @provider)
    params = { id: layout.id, cms_template: { draft: '<abc>0</abc>' }}

    (ENV['BRUTOFORCE'].present? ? 200 : 1).times do |i|
      params[:cms_template][:draft] = "<abc>#{i}</abc>"
      put provider_admin_cms_layout_path(params)
      assert_response :redirect
      assert_equal "<abc>#{i}</abc>", layout.reload.draft
    end

    params[:cms_template][:not_existing] = 'alaska'
    System::ErrorReporting.expects(:report_error).never
    put provider_admin_cms_layout_path(params)
  end
end
