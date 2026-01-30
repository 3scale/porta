# frozen_string_literal: true

module PaymentDetailsHelper
  delegate :billing_address, to: :current_account

  attr_reader :braintree_authorization

  def credit_card_terms_url
    url_for(site_account.settings.cc_terms_path)
  end

  def credit_card_privacy_url
    url_for(site_account.settings.cc_privacy_path)
  end

  def credit_card_refunds_url
    url_for(site_account.settings.cc_refunds_path)
  end

  def link_to_payment_details(text, options = {})
    link_to text, payment_details_path, options
  end

  def payment_details_path(merchant_account = site_account, url_params = {})
    return '' if merchant_account.unacceptable_payment_gateway?

    named_route = [:admin, :account, merchant_account.payment_gateway_type]
    polymorphic_path(named_route, url_params)
  end

  # This smells of :reek:FeatureEnvy but it shouldn't
  def merchant_countries
    @merchant_countries ||= ActiveMerchant::Country::COUNTRIES.map { |country| [country[:name], country[:alpha2]] }.uniq
  end

  def payment_details_definition_list_item(name, account)
    value = account.public_send("billing_address_#{name}")
    return if value.blank?

    definition_list_item = tag.dt(name.to_s.titleize, class: 'u-dl-term')
    definition_list_item += tag.dd(value.presence, class: 'u-dl-definition')
    definition_list_item
  end

  def stripe_form_data(intent)
    {
      stripePublishableKey: site_account.payment_gateway_options[:publishable_key],
      setupIntentSecret: intent.client_secret,
      billingAddress: stripe_billing_address,
      billingName: current_account[:billing_address_name],
      successUrl: hosted_success_admin_account_stripe_path,
      creditCardStored: current_account.credit_card_stored?
    }.compact
  end

  # Must match PaymentMethod's address format https://stripe.com/docs/api/payment_methods/object#payment_method_object-billing_details-address
  def stripe_billing_address
    return unless logged_in?

    {
      line1: billing_address.address1,
      line2: billing_address.address2,
      city: billing_address.city,
      state: billing_address.state,
      postal_code: billing_address.zip,
      country: billing_address.country # Contrary to Braintree, the Stripe form sends the country as an ISO code.
    }.compact
  end

  def braintree_form_data
    {
      formActionPath: developer_portal.hosted_success_admin_account_braintree_blue_path,
      threeDSecureEnabled: site_account.payment_gateway_options[:three_ds_enabled],
      clientToken: braintree_authorization,
      countriesList: merchant_countries,
      billingAddress: billing_address_data,
      ipAddress: ip_address
    }
  end

  def billing_address_data # rubocop:disable Metrics/AbcSize
    country = billing_address[:country]
    {
      firstName: current_account.billing_address_first_name,
      lastName: current_account.billing_address_last_name,
      address: billing_address[:address1],
      city: billing_address[:city],
      country: country,
      countryCode: country_code_for(country),
      company: billing_address[:company],
      phone: billing_address[:phone_number],
      state: billing_address[:state],
      zip: billing_address[:zip]
    }.transform_values { |value| value.presence || '' }
  end

  def country_code_for(country_name)
    return nil unless country_name

    merchant_countries.find { |country| country[0] == country_name }&.dig(1)
  end

  def ip_address
    request&.remote_ip
  end

  # :reek:ControlParameter but it's OK
  def boolean_status_img(enabled)
    if enabled
      '<i class="included fas fa-check-circle" title="Enabled"></i>'.html_safe
    else
      '<i class="excluded fas fa-times-circle" title="Disabled"></i>'.html_safe
    end
  end
end
