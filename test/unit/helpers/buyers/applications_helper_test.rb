# frozen_string_literal: true

require 'test_helper'

class Buyers::ApplicationsHelperTest < ActionView::TestCase

  def setup
    @product = { name: 'Service' }
    ServiceDecorator.any_instance.stubs(:new_application_data).returns(@product)
    ProviderDecorator.any_instance.stubs(:application_products_data).returns([@product])

    @buyer = { name: 'Buyer' }
    BuyerDecorator.any_instance.stubs(:new_application_data).returns(@buyer)
    ProviderDecorator.any_instance.stubs(:application_buyers_data).returns([@buyer])

    @fields = { name: 'Field' }
    ProviderDecorator.any_instance.stubs(:application_defined_fields_data).returns([@fields])
  end

  test 'new_application_form_metadata in Dashboard context' do
    provider = FactoryBot.create(:provider_account)

    data = new_application_form_metadata(provider)
    assert_equal data[:products], [@product].to_json
    assert_equal data[:buyers], [@buyer].to_json
    assert_equal data[:'defined-fields'], [@fields].to_json
  end

  test 'new_application_form_metadata in Account context' do
    provider = FactoryBot.create(:provider_account)
    buyer = FactoryBot.create(:buyer_account)

    data = new_application_form_metadata(provider, buyer: buyer)
    assert_equal data[:buyer], @buyer.to_json
    assert_equal data[:products], [@product].to_json
    assert data[:'create-application-path']
  end

  test 'new_application_form_metadata in Product context' do
    provider = FactoryBot.create(:provider_account)
    service = FactoryBot.create(:simple_service)

    data = new_application_form_metadata(provider, service: service)
    assert_equal data[:product], @product.to_json
    assert_equal data[:buyers], [@buyer].to_json
  end

  test 'new_application_form_metadata inline errors' do
    provider = FactoryBot.create(:provider_account)
    cinstance = FactoryBot.create(:cinstance)
    errors = ['Name is required']
    cinstance.stubs(:errors).returns(errors)

    data = new_application_form_metadata(provider, cinstance: cinstance)
    assert_equal data[:errors], errors.to_json
  end

  test "remaining_trial_days should return the right expiration date text" do
    time = Time.utc(2015, 1,20, 10, 10, 10)
    cinstance = FactoryBot.build(:cinstance, trial_period_expires_at: time)
    expected_date = '&ndash; trial expires in <time datetime="2015-01-20T10:10:10Z" title="20 Jan 2015 10:10:10 UTC">20 days</time>'

    Timecop.freeze(time - 20.days) do
      assert_equal expected_date, remaining_trial_days(cinstance)
    end
  end
end
