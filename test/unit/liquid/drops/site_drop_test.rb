require 'test_helper'

class Liquid::Drops::SiteDropTest < ActiveSupport::TestCase
  include Liquid

  setup do
    @provider = FactoryBot.create(:provider_account)
    @drop     = Drops::Site.new(@provider)
  end


  test '#authentication_providers' do
    assert @drop.authentication_providers.respond_to?(:each)

    FactoryBot.create(:github_authentication_provider, published: true, account: @provider)
    FactoryBot.create(:keycloak_authentication_provider, published: false, account: @provider)

    FactoryBot.create(:github_authentication_provider, published: true, account: master_account)
    FactoryBot.create(:keycloak_authentication_provider, published: false, account: master_account)

    # Should return published authentication providers from the account and
    # master account
    assert_equal 1, @drop.authentication_providers.count

    # Test that all the authentication providers are published
    assert AuthenticationProvider.where(id: @drop.authentication_providers.map(&:id)).pluck(:published).all?

    # Should return published authentication providers from the account
    assert_equal 1, @drop.authentication_providers.count
  end
end
