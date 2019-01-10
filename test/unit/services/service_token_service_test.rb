require 'test_helper'

class ServiceTokenServiceTest < ActiveSupport::TestCase
  def test_update_backend
    token = ServiceToken.new(value: 'foo', service_id: 42)

    ThreeScale::Core::ServiceToken.expects(:save!)
      .with({ 'foo' => { service_id: 42 } }).returns(true)

    ServiceTokenService.update_backend(token)
  end

  def test_delete_backend
    service = FactoryBot.create(:simple_service)
    token = service.service_tokens.first!

    ThreeScale::Core::ServiceToken.expects(:delete).with([{ service_token: token.value, service_id: service.id }])
    ServiceTokenService.delete_backend(token)
  end
end
