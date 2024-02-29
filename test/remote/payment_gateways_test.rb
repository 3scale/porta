require 'test_helper'

class PaymentGatewaysTest < ActiveSupport::TestCase
  def setup
    @provider_account = FactoryBot.create(:provider_account)
    @provider_account.billing_strategy = FactoryBot.create(:postpaid_billing)

    @buyer_account = FactoryBot.create(:buyer_account, :provider_account => @provider_account)

    @billing_address= {
          :name     => 'John Doe',
          :address1 => '123 State Street',
          :address2 => 'Apartment 1',
          :city     => 'Nowhere',
          :state    => 'MT',
          :country  => 'US',
          :zip      => '55555',
          :phone    => '555-555-5555'
    }


    @credit_card = {
      :first_name => 'Eric',
      :last_name => 'Cartman',
      :number => '4111111111111111',
      :year => 1.year.from_now.year,
      :month => 6,
      :verification_value => '123'
    }

    @cc = ActiveMerchant::Billing::CreditCard.new(@credit_card)

  end

  # test 'braintree gateway' do
  #   @provider_account.payment_gateway_type = :braintree
  #   @provider_account.payment_gateway_options = {:login => 'testapi', :password => 'password1'}
  #   @provider_account.save!
  #   @buyer_account.credit_card = @credit_card
  #   @buyer_account.save!

  #   transaction = @buyer_account.charge!(100.to_has_money('EUR'))

  #   assert transaction.success?
  #   assert_equal 100.to_has_money('EUR'), transaction.amount
  # end

  # test 'braintree blue gateway' do
  #   @provider_account.payment_gateway_type = :braintree_blue
  #   @provider_account.payment_gateway_options = {:public_key => 'cxqsb7m5sqjd839g', :merchant_id => '78v75b9sxb3x5ybk', :private_key => 'nqs5txx8xdm32f34'}
  #   @provider_account.save!
  #   @buyer_account.credit_card = @credit_card
  #   @buyer_account.save!

  #   transaction = @buyer_account.charge!(100.to_has_money('EUR'))

  #   assert transaction.success?
  #   assert_equal 100.to_has_money('EUR'), transaction.amount
  # end

end
