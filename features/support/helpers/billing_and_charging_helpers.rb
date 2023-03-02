# frozen_string_literal: true

module BillingAndChargingHelpers
  # This smells of :reek:sssBooleanParameter but we don't care
  # FIXME: :reek:UtilityFunction
  def set_provider_charging_with(provider:, payment_gateway:, charging_enabled: true)
    settings = provider.settings
    settings.allow_finance! if settings.finance.denied?

    provider.billing_strategy.update!(charging_enabled: charging_enabled, currency: 'EUR')
    # TODO: extract payment_gateway_options into a helper method and generate based on payment_gateway
    provider.update!(payment_gateway_type: payment_gateway,
                     payment_gateway_options: { login: 'login',
                                                password: 'password',
                                                user: 'user',
                                                merchant_id: 'merchant_id',
                                                public_key: 'public_key',
                                                private_key: 'private_key',
                                                publishable_key: 'pk_test_51LuDq8H2pBu3kj9oWooGacO6Im2UbBvgCFYMo3eZsNf6EkJzLpZY4jgNFPO2sijRh4fvhfoqezEkaRBYoh1Wmn3b00V5Luq0X9' })
  end
end

World(BillingAndChargingHelpers)
