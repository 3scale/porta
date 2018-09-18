require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Api::ErrorsControllerTest < ActionController::TestCase
  context 'provider' do
    setup do
      @provider = FactoryGirl.create(:simple_provider, self_domain: 'test.host')
    end
  end

  test "get index with pagination" do
    provider = Factory(:provider_account)
    service = provider.services.first

    stub_backend_service_errors(service, fake_errors)
    login_provider provider

    get :index, per_page: 1, page: 2
    assert_equal service, assigns(:service_errors).first.first
  end

  private

  def fake_errors
    [{ timestamp: Time.now.iso8601, message: "fake error 1"}]
  end
end
