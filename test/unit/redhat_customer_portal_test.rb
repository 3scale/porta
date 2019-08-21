require 'test_helper'

class AuthenticationProviders::RedHatCustomerPortalTest < ActiveSupport::TestCase

  test 'authentication provider is frozen' do
    assert AuthenticationProviders::RedhatCustomerPortal.build.frozen?
  end

  test 'authentication provider preserves eventual config attributes passed' do
    ThreeScale.config.redhat_customer_portal.stubs(realm: 'default-realm')

    authentication_provider = AuthenticationProviders::RedhatCustomerPortal.build(realm: 'my-custom-realm')
    assert_equal 'my-custom-realm', authentication_provider.realm
  end

  test 'authentication provider is readonly' do
    assert AuthenticationProviders::RedhatCustomerPortal.build.readonly?
  end
end
