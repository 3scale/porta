require 'test_helper'

class ServiceContracts::ServiceContractCreatedEventTest < ActiveSupport::TestCase

  def test_create
    contract = FactoryBot.build_stubbed(:simple_service_contract, id: 1)
    user     = FactoryBot.build_stubbed(:simple_user, id: 2)
    event    = ServiceContracts::ServiceContractCreatedEvent.create(contract, user)

    assert event
    assert_equal event.service_contract, contract
    assert_equal event.provider, contract.provider_account
    assert_equal event.user, user
  end
end
