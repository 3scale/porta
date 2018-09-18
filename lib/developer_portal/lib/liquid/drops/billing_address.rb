class Liquid::Drops::BillingAddress < Liquid::Drop

  def initialize(account)
    @account = account
  end

  def name
    @account.billing_address_name
  end

  def address1
    @account.billing_address_address1
  end

  def address2
    @account.billing_address_address2
  end

  def address
    "#{@account.billing_address_address1} #{@account.billing_address_address2}"
  end

  def city
    @account.billing_address_city
  end

  def state
    @account.billing_address_state
  end

  def country
    if c = ::Country.find_by_code(@account.billing_address.country)
      Liquid::Drops::Country.new(c)
    else
      @account.billing_address.country
    end
  end

  def zip
    @account.billing_address_zip
  end

  def phone
    @account.billing_address_phone
  end

  def fields
    [
     Liquid::Drops::BillingAddressField.new(@account.billing_address, :name),
     Liquid::Drops::BillingAddressField.new(@account.billing_address, :address1),
     Liquid::Drops::BillingAddressField.new(@account.billing_address, :address2),
     Liquid::Drops::BillingAddressField.new(@account.billing_address, :city),
     Liquid::Drops::BillingAddressField.new(@account.billing_address, :country),
     Liquid::Drops::BillingAddressField.new(@account.billing_address, :state),
     Liquid::Drops::BillingAddressField.new(@account.billing_address, :phone),
     Liquid::Drops::BillingAddressField.new(@account.billing_address, :zip)
    ]
  end

  def errors
    @__errors ||= Liquid::Drops::Errors.new(@account.billing_address)
  end

end
