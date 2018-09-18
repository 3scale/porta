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
    ActiveMerchant::Country::COUNTRIES.map{|c| c[:name] }
  end

  #TODO: move these two methods to another helper
  def build_url(path)
    full_path = "#{site_account.domain}#{local_postfix_and_port}/#{path}".gsub(/[\/]+/, '/')
    "https://#{full_path}"
  end

  def local_postfix_and_port
    if ["test", "development"].include?(Rails.env)
      request.host_with_port.gsub(site_account.domain, '').gsub(/\/.*/, '/')
    end
  end

  def payment_details_definition_list_item(name, account)
    value = account.public_send("billing_address_#{name}")
    return unless value.present?

    definition_list_item = content_tag :dt, name.to_s.titleize, class: 'u-dl-term'
    definition_list_item += content_tag :dd, value.presence, class: 'u-dl-definition'
    definition_list_item
  end
end
