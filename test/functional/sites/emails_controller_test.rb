require 'test_helper'

class Sites::EmailsControllerTest < ActionController::TestCase

  def setup
    @provider  = FactoryBot.create(:provider_account)
    @service = @provider.default_service
    request.host = @provider.external_admin_domain
    login_as(@provider.admins.first)
  end

  test 'show Service name sanitized' do
    service_name_xss = "API<script>alert('XSS')</script>"
    service_name_xss_sanitized = "APIalert('XSS')"
    @service.name = service_name_xss
    @service.save!

    get :edit
    assert_response :success
    assert_select '#account_service_support_email_input label', "Service #{ service_name_xss_sanitized }"
  end

end
