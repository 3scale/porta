# frozen_string_literal: true

require 'test_helper'

class ServiceContractMessengerTest < ActiveSupport::TestCase
  def setup
    @contract = FactoryBot.create(:service_contract)
    @provider = @contract.provider_account
    @plan = @contract.plan
    @buyer = @contract.user_account
    @service = @contract.service

    ServiceContractMessenger.new_contract(@contract).deliver
    @message = Message.last
  end

  test 'should be sent' do
    assert @message.sent?
  end

  test 'should have the provider as recipient' do
    assert_equal [@provider], @message.to
  end

  test 'should have meaningful subject' do
    assert_match /service subscription/i, @message.subject
  end

  test 'should contain service name' do
    assert_match @service.name, @message.body
  end

  test 'should contain plan name' do
    assert_match @plan.name, @message.body
  end

  test 'should contain buyer name' do
    assert_match @buyer.org_name, @message.body
  end

  test 'should contain buyer email' do
    assert_match @buyer.admins.first.email, @message.body
  end
end
