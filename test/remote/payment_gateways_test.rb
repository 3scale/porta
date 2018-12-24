require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'fakeweb'

class PaymentGatewaysTest < ActiveSupport::TestCase
  def setup
    @provider_account = FactoryBot.create(:provider_account)
    @provider_account.billing_strategy = FactoryBot.create(:postpaid_billing)

    @buyer_account = FactoryBot.create(:buyer_account, :provider_account => @provider_account)
    FakeWeb.allow_net_connect = true

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

  def teardown
    FakeWeb.allow_net_connect = false
  end

  # test 'ogone gateway' do
  #   @provider_account.payment_gateway_type = :ogone
  #   @provider_account.payment_gateway_options = {:signature => 'Mysecretsig1875!?', :login => '3scalenetworks', :user => '3SCALEPAPI', :password => 'URIEDA33'}
  #   @provider_account.save!

  #   @buyer_account.credit_card = @credit_card
  #   @buyer_account.billing_address = @billing_address
  #   @buyer_account.save!

  #   transaction = @buyer_account.charge! BigDecimal.new("1.81")

  #   assert transaction.success?
  #   assert_equal 1.81.to_has_money('EUR'), transaction.amount
  # end

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

  test 'authorize.net gateway' do
    @provider_account.payment_gateway_type = :authorize_net
    @provider_account.payment_gateway_options = {login: '5qA7rB4v2', password: '9x586KTvfsC5f9EP'}
    @provider_account.save!

    unique = Digest::SHA1.hexdigest(Time.now.to_s).first(10)
    @buyer_account.admins.first.update_attribute(:email, "test-#{unique}@example.com")

    set_payment_profile_for_authorize_net(@buyer_account)
    @buyer_account.save!

    transaction = @buyer_account.charge!(100.to_has_money('EUR'))

    assert transaction.success?
    assert_equal 100.to_has_money('EUR'), transaction.amount
    assert_equal 100.to_f, transaction.params['direct_response']['amount'].to_f
  end

  private

  def set_payment_profile_for_authorize_net(buyer)
    pg = ::ActiveMerchant::Billing::AuthorizeNetCimGateway.new(buyer.provider_account.payment_gateway_options)
    unique = Digest::SHA1.hexdigest(Time.now.to_s).first(10)

    response = pg.create_customer_profile(profile: {email: buyer.admins.first.email})
    id = response.params["customer_profile_id"]

    prof = pg.create_customer_payment_profile(customer_profile_id: id,
                                              payment_profile:{ customer_type: 'individual',
                                                payment:{credit_card: credit_card_attributes_for_authorize_net}})

    buyer.update_attribute(:credit_card_auth_code, id)
    buyer.update_attribute(:credit_card_authorize_net_payment_profile_token , prof.params["customer_payment_profile_id"])
  end

  def credit_card_attributes_for_authorize_net
    OpenStruct.new(:first_name => 'Eric',
      :last_name => 'Cartman',
      :number => '4007000000027',
      :year => 1.year.from_now.year,
      :month => 6,
      :verification_value => '999')
  end
end
