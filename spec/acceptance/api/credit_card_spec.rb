require 'rails_helper'

resource "Account" do

  let(:resource) { FactoryBot.create(:buyer_account, provider_account: provider) }

  api 'credit card' do
    let(:account_id) { resource.id }
    include_context "resource"

    put '/admin/api/accounts/:account_id/credit_card.:format' do
      parameter :credit_card_token, "The token returned by the payment gateway."
      parameter :credit_card_expiration_year, "Year of expiration of credit card"
      parameter :credit_card_expiration_month, "Month of expiration of credit card"
      parameter :billing_address_name, "Name of the person/company to bill"
      parameter :billing_address_address, "Address associated to the credit card"
      parameter :billing_address_city, "Billing address city"
      parameter :billing_address_country, "Billing address country"

      let(:credit_card_token) { '12324354' }
      let(:credit_card_expiration_year) { '2013' }
      let(:credit_card_expiration_month) { '01' }
      let(:billing_address_name) { 'John Doe' }
      let(:billing_address_address) { 'Area 51' }
      let(:billing_address_city) { 'Nevada' }
      let(:billing_address_country) { 'Arizona' }

      request "Store Credit Card" do
        resource.reload.credit_card_stored?.should == true
      end
    end

    delete '/admin/api/accounts/:account_id/credit_card.xml' do
      before { resource.update_attribute(:credit_card_auth_code, true) }

      request "Destroy stored Credit Card", body: false do
        resource.reload.credit_card_stored?.should == false
      end
    end
  end

end

__END__
admin_api_account_credit_card PUT    /admin/api/accounts/:account_id/credit_card(.:format) admin/api/credit_cards#update {:format=>"xml"}
                              DELETE /admin/api/accounts/:account_id/credit_card(.:format) admin/api/credit_cards#destroy {:format=>"xml"}