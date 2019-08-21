class FixInheritanceColumnTypeForAuthenticationProviders < ActiveRecord::Migration
  def change
    AuthenticationProvider.where(type: 'AuthenticationProvider::Auth0').update_all(type: 'AuthenticationProviders::Auth0')
    AuthenticationProvider.where(type: 'AuthenticationProvider::Custom').update_all(type: 'AuthenticationProviders::Custom')
    AuthenticationProvider.where(type: 'AuthenticationProvider::GitHub').update_all(type: 'AuthenticationProviders::GitHub')
    AuthenticationProvider.where(type: 'AuthenticationProvider::Keycloak').update_all(type: 'AuthenticationProviders::Keycloak')
    AuthenticationProvider.where(type: 'AuthenticationProvider::RedhatCustomerPortal').update_all(type: 'AuthenticationProviders::RedhatCustomerPortal')
    AuthenticationProvider.where(type: 'AuthenticationProvider::ServiceDiscoveryProvider').update_all(type: 'AuthenticationProviders::ServiceDiscoveryProvider')
  end
end
