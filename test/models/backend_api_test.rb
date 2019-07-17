require 'test_helper'

class BackendApiConfigTest < ActiveSupport::TestCase
  def setup
    @account = FactoryBot.build(:simple_provider)
    @backend = BackendApi.new(account: @account)
  end

  def test_default_api_backend
    assert_equal "https://echo-api.3scale.net:443", @backend.default_api_backend
    assert_equal "https://echo-api.3scale.net:443", BackendApi.default_api_backend
  end

  test 'proxy api backend with base path' do
    @account.stubs(:provider_can_use?).with(:apicast_v1).returns(true)
    @account.stubs(:provider_can_use?).with(:apicast_v2).returns(true)
    @account.expects(:provider_can_use?).with(:proxy_private_base_path).at_least_once.returns(false)
    @backend_api.private_endpoint = 'https://example.org:3/path'
    @backend_api.valid?
    assert_equal [@backend_api.errors.generate_message(:api_backend, :invalid)], @backend_api.errors.messages[:api_backend]

    @account.expects(:provider_can_use?).with(:proxy_private_base_path).at_least_once.returns(true)
    @proxy.api_backend = 'https://example.org:3/path'
    assert @proxy.valid?
  end
end
