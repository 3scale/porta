# frozen_string_literal: true

class DeveloperPortal::AbstractPaymentGatewaysControllerTest < DeveloperPortal::ActionController::TestCase

  class_attribute :payment_gateway_type, instance_writer: false

  module DefaultPaymentGatewayType
    def payment_gateway_type
      super || self.payment_gateway_type = self.determine_default_payment_gateway_type
    end

    def determine_default_payment_gateway_type
      self.controller_class.controller_name.to_sym
    end
  end

  class << self
    prepend DefaultPaymentGatewayType
  end

  def setup_provider
    @provider = create_provider_with_gateway_setting

    FactoryGirl.create(:postpaid_billing, charging_enabled: true, account: @provider)

    @provider.settings.update_attribute(:finance_switch, 'visible')
    @service = @provider.default_service
    @service.update_attribute :buyer_plan_change_permission, 'request_credit_card'

    @buyer = FactoryGirl.create(:buyer_account, provider_account: @provider)
    @buyer.buy! @service.service_plans.first
    admin = @buyer.admins.first
    @account = admin.account

    @plan  = FactoryGirl.create :application_plan, issuer: @service, name: 'current plan'
    @plan.publish!

    @application = @buyer.buy! @plan
    @buyer.reload

    @paid_plan  = FactoryGirl.create :application_plan, issuer: @service, setup_fee: 10, name: 'paid plan'
    @paid_plan.publish!
    @free_plan  = FactoryGirl.create :application_plan, issuer: @service, name: 'free plan'
    @free_plan.publish!

    host! @provider.domain

    login_as admin
  end

  def create_provider_with_gateway_setting
    FactoryGirl.create(:provider_account, payment_gateway_type: payment_gateway_type, payment_gateway_options: payment_gateway_fields)
  end

  def payment_gateway_fields
    PaymentGateway.find(payment_gateway_type).fields
  end

  setup :setup_provider
end
