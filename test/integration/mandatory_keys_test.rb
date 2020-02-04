require 'test_helper'

class MandatoryKeysTest < ActionDispatch::IntegrationTest
  context 'Mandatory keys: ' do

    setup do
      @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'
      @plan = FactoryBot.create :application_plan, :issuer => @provider.default_service
      @service = @provider.first_service!
      @service.update_attribute(:backend_version, '2')
      @buyer = FactoryBot.create :buyer_account, :provider_account => @provider

      ApplicationKey.disable_backend!
    end

    context 'service has mandatory_app_key' do
      setup do
        @service.update_attribute(:mandatory_app_key, true)
      end

      should 'create a key on app creation' do
        app = @buyer.buy! @plan

        assert_equal 1, app.application_keys.size
      end

      should 'create not be able to delete the last key'
    end

    context "service hasn't mandatory_app_key" do
      setup do
        @service.update_attribute(:mandatory_app_key, false)
      end

      should 'not create a key on app creation' do
        app = @buyer.buy! @plan

        assert_equal 0, app.application_keys.size
      end
    end
  end
end
