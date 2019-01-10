# frozen_string_literal: true

require_relative 'abstract_payment_gateways_controller_test'

# Inherit from this class instead of DeveloperPortal::AbstractPaymentGatewaysControllerTest to deprecate payment gateways
class DeveloperPortal::DeprecatedPaymentGatewaysControllerTest < DeveloperPortal::AbstractPaymentGatewaysControllerTest
  def create_provider_with_gateway_setting
    provider = FactoryBot.build(:provider_account, payment_gateway_type: payment_gateway_type, payment_gateway_options: payment_gateway_fields)
    provider.save(validate: false) # to prevent ActiveRecord::RecordInvalid since the payment gateway has been deprecated
    provider.reload
  end
end
