require 'test_helper'

class ServiceContractMessengerTest < ActiveSupport::TestCase

  def setup
    @contract = Factory(:service_contract)
    @provider = @contract.provider_account
    @plan = @contract.plan
    @buyer = @contract.user_account
    @service = @contract.service
  end

  context 'new contract message' do

    setup do
      ServiceContractMessenger.new_contract(@contract).deliver
      @message = Message.last
    end

    should 'be sent' do
      assert @message.sent?
    end

    should 'have the provider as recipient' do
      assert_equal [@provider], @message.to
    end

    should 'have meaningful subject' do
      assert_match /service subscription/i, @message.subject
    end

    should 'contain service name' do
      assert_match @service.name, @message.body
    end

    should 'contain plan name' do
      assert_match @plan.name, @message.body
    end

    should 'contain buyer name' do
      assert_match @buyer.org_name, @message.body
    end

    should 'contain buyer email' do
      assert_match @buyer.admins.first.email, @message.body
    end
  end

end
