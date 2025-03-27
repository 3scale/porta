# frozen_string_literal: true

require 'test_helper'

class ServiceContractMessengerTest < ActiveSupport::TestCase
  def setup
    @contract = FactoryBot.create(:service_contract)
    @provider = @contract.provider_account
    @plan = @contract.plan
    @buyer = @contract.user_account
    @service = @contract.service

    ServiceContractMessenger.accept(@contract).deliver
    @message = Message.last
  end

  test 'should be sent' do
    assert @message.sent?
  end

  test 'should have the buyer as recipient' do
    assert_equal [@buyer], @message.to
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

  test 'should contain provider name' do
    assert_match @provider.org_name, @message.body
  end

  test 'should contain provider email' do
    assert_match @provider.admins.first.email, @message.body
  end
end
