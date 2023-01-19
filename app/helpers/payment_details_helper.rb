# frozen_string_literal: true

module PaymentDetailsHelper
  delegate :has_billing_address?, :billing_address, to: :current_account

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
    payment_gateway_type = merchant_account.payment_gateway_type
    return "" if ["bogus",""].include?(payment_gateway_type.to_s)

    named_route = [:admin, :account, payment_gateway_type]
    polymorphic_path(named_route, url_params)
  end

  def edit_payment_details(merchant_account = site_account)
    payment_gateway_type = merchant_account.payment_gateway_type
    return "" if ["bogus",""].include?(payment_gateway_type.to_s)

    polymorphic_url([:edit, :admin, :account, payment_gateway_type])
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

  def stripe_billing_address_json
    return unless logged_in?

    {
      line1: billing_address.address1,
      line2: billing_address.address2,
      city: billing_address.city,
      state: billing_address.state,
      postal_code: billing_address.zip,
      country: billing_address.country
    }.to_json
  end

  def get_country_code(country)
    _label, code = merchant_countries.find {|label, code| label.downcase == country.to_s.downcase }
    code
  end

  def selected_country_code
    has_billing_address? ? get_country_code(billing_address.country) : ''
  end

  def braintree_form_data
    {
      formActionPath: developer_portal.hosted_success_admin_account_braintree_blue_path,
      threeDSecureEnabled: site_account.payment_gateway_options[:three_ds_enabled],
      clientToken: braintree_authorization,
      countriesList: merchant_countries,
      billingAddress: has_billing_address? ? billing_address_data : empty_billing_address_data
    }
  end

  def billing_address_data # rubocop:disable Metrics/AbcSize
    {
      firstName: current_account.billing_address_first_name,
      lastName: current_account.billing_address_last_name,
      address: billing_address[:address1],
      city: billing_address[:city],
      country: billing_address[:country],
      company: billing_address[:company],
      phone: billing_address[:phone_number],
      state: billing_address[:state],
      zip: billing_address[:zip]
    }.transform_values { |value| value.presence || '' }
  end

  def empty_billing_address_data
    {
      firstName: '',
      lastName: '',
      address: '',
      city: '',
      country: '',
      company: '',
      phone: '',
      state: '',
      zip: ''
    }
  end
end
