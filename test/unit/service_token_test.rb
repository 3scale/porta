require 'test_helper'

class ServiceTokenTest < ActiveSupport::TestCase

  def test_valid?
    service_token = ServiceToken.new

    refute service_token.valid?
    assert service_token.errors[:service].present?
    assert service_token.errors[:value].present?

    service_token.value = SecureRandom.hex(45)

    refute service_token.valid?
    assert service_token.errors[:service].present?
    refute service_token.errors[:value].present?

    service_token.service = FactoryGirl.build_stubbed(:simple_service)

    assert service_token.valid?
    refute service_token.errors[:service].present?
    refute service_token.errors[:value].present?

    service_token.value = SecureRandom.hex(51)

    refute service_token.valid?
    refute service_token.errors[:service].present?
    assert service_token.errors[:value].join.include?('is too long')
  end

  test 'ServiceTokenDeletedEvent is created and published when service token is destroyed' do
    service_token = FactoryGirl.create(:service_token)
    ServiceTokenDeletedEvent.expects(:create_and_publish!).with(service_token)
    service_token.destroy!
  end
end
