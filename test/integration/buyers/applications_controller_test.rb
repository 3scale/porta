require 'test_helper'

class Buyers::ApplicationsTest < ActionDispatch::IntegrationTest
  def setup
    @provider = Factory(:provider_account)

    host! @provider.admin_domain
    provider_login_with @provider.admins.first.username, "supersecret"

    #TODO: dry with @ignore-backend tag on cucumber
    stub_backend_get_keys
    stub_backend_referrer_filters
    stub_backend_utilization
  end

  test 'index shows the services column when the provider is multiservice' do
    @provider.services.create!(name: '2nd-service')
    assert @provider.reload.multiservice?
    get admin_buyers_applications_path
    page = Nokogiri::HTML::Document.parse(response.body)
    assert page.xpath("//tr").text.match /Service/
  end

  test 'index does not show the services column when the provider is not multiservice' do
    refute @provider.reload.multiservice?
    get admin_buyers_applications_path
    page = Nokogiri::HTML::Document.parse(response.body)
    refute page.xpath("//tr").text.match /Service/
  end

end
