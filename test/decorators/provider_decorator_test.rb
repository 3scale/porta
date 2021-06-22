# frozen_string_literal: true

require 'test_helper'

class ProviderDecoratorTest < Draper::TestCase

  def setup
    provider = FactoryBot.create(:provider_account)
    @decorator = ProviderDecorator.new provider
    @decorator.stubs(:service_plans_management_visible?).returns(true)
  end

  test 'new_application_form_data in Dashboard context' do
    @decorator.expects(:audience_context_new_application_form_data).returns({}).once

    assert @decorator.new_application_form_data
  end

  test 'new_application_form_data in Account context' do
    buyer = FactoryBot.create(:buyer_account)
    @decorator.expects(:buyer_context_new_application_form_data).with(buyer).returns({}).once

    assert @decorator.new_application_form_data(buyer: buyer)
  end

  test 'new_application_form_data in Product context' do
    service = FactoryBot.create(:service)
    @decorator.expects(:product_context_new_application_form_data).with(service).returns({}).once

    assert @decorator.new_application_form_data(service: service)
  end

  test 'new_application_form_data inline errors' do
    cinstance = FactoryBot.create(:cinstance)
    errors = ['Name is required']
    cinstance.stubs(:errors).returns(errors)
    @decorator.expects(:audience_context_new_application_form_data).returns({}).once

    assert_equal errors.to_json, @decorator.new_application_form_data(cinstance: cinstance)[:errors]
  end
end
