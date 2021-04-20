# frozen_string_literal: true

module PaymentDetailsHelper

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
    return "" if ["bogus" ,""].include?(merchant_account.payment_gateway_type.to_s)
    named_route = [:admin, :account, merchant_account.payment_gateway_type]
    polymorphic_path(named_route, url_params)
  end

  def edit_payment_details(merchant_account = site_account)
    return "" if ["bogus" ,""].include?(merchant_account.payment_gateway_type.to_s)
    polymorphic_url([:edit, :admin, :account, merchant_account.payment_gateway_type])
  end

  def merchant_countries
    ActiveMerchant::Country::COUNTRIES.map{|c| [c[:name], c[:alpha2]] }
  end

  def payment_details_definition_list_item(name, account)
    value = account.public_send("billing_address_#{name}")
    return unless value.present?

    definition_list_item = content_tag :dt, name.to_s.titleize, class: 'u-dl-term'
    definition_list_item += content_tag :dd, value.presence, class: 'u-dl-definition'
    definition_list_item
  end

  def stripe_billing_address_json
    return unless logged_in?

    billing_address = current_account.billing_address
    {
      line1: billing_address.address1,
      line2: billing_address.address2,
      city: billing_address.city,
      state: billing_address.state,
      postal_code: billing_address.zip,
      country: billing_address.country
    }.to_json
  end

  def get_country_code(billing_address_data)
    _label, code = merchant_countries.find {|label, code| label.downcase == billing_address_data.country.to_s.downcase }
    code
  end 

end
