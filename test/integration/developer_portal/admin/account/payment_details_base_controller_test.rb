# frozen_string_literal: true

class DeveloperPortal::Admin::Account::PaymentDetailsBaseTest < ActionDispatch::IntegrationTest
  include System::UrlHelpers.cms_url_helpers

  setup do
    @provider = FactoryBot.create(:provider_with_billing)

    @provider.settings.allow_finance!
    @provider.settings.show_finance!

    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider.reload)
    login_buyer @buyer
  end

  test '#update should only accept billing address params' do
    account_params = {
      billing_address: {
        name: 'Tim',
        address1: 'Booked 2',
        address2: 'Second Line of Address',
        city: 'Timbuktu',
        state: 'Mali',
        zip: '10100',
        phone: '+123 456 789',
        country: 'ES'
      }
    }.deep_stringify_keys

    Account.any_instance.expects(:update_attributes).with(account_params).returns(true)
    put admin_account_payment_details_path, params: { account: account_params.deep_merge('billing_address' => { 'injected_param' => 'unauthorized' }) }
  end
end
