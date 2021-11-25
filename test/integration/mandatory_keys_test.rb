# frozen_string_literal: true

require 'test_helper'

class MandatoryKeysTest < ActionDispatch::IntegrationTest
  setup do
    provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    @service = FactoryBot.create(:simple_service, account: provider, backend_version: 2)
    @plan = FactoryBot.create(:application_plan, issuer: @service)
    @buyer = FactoryBot.create(:buyer_account, provider_account: provider)

    ApplicationKey.disable_backend!
  end

  class ServiceWithMandatoryAppKeyTest < self
    def setup
      super
      @service.update(mandatory_app_key: true)
    end

    test 'create a key on app creation' do
      app = @buyer.buy! @plan

      assert_equal 1, app.application_keys.size
    end

    test 'not be able to delete the last key' do
      app = @buyer.buy! @plan
      assert_not app.can_delete_key?

      app.application_keys.new
      assert app.can_delete_key?
    end
  end

  class ServiceWithoutMandatoryAppKeyTest < self
    def setup
      super
      @service.update(mandatory_app_key: false)
    end

    test 'not create a key on app creation' do
      app = @buyer.buy! @plan

      assert_equal 0, app.application_keys.size
    end

    test 'be able to delete keys' do
      app = @buyer.buy! @plan
      assert app.can_delete_key?
    end
  end
end
