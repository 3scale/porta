require 'test_helper'

class Liquid::Drops::ServiceContractDroptest < ActiveSupport::TestCase

  def setup
    @service_contract = FactoryBot.create(:service_contract)
    @drop = Liquid::Drops::ServiceContract.new(@service_contract)
  end

  test 'can.change_plan?' do
    settings = @service_contract.provider_account.settings

    settings.allow_service_plans!
    settings.service_plans.show!
    assert @drop.can.change_plan?

    settings.service_plans.hide!
    refute @drop.can.change_plan?
  end

end
