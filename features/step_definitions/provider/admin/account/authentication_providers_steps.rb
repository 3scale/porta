# frozen_string_literal: true

Given 'a red hat single sign-on integration' do
  @rhsso_integration = AuthenticationProvider::Keycloak.create!(client_id: 'doctor', client_secret: 'tardis', realm: 'https://rh-sso.doctor.com/auth/realms/demo',
                                           account_type: AuthenticationProvider.account_types[:provider], account: @provider)
end

Given 'an auth0 integration' do
  AuthenticationProvider::Auth0.create!(client_id: 'doctor', client_secret: 'tardis', site: 'https://doctor.auth0.com',
                                           account_type: AuthenticationProvider.account_types[:provider], account: @provider)
end

Given 'a developer portal red hat single sign-on integration' do
  @rhsso_dev_portal_integration = AuthenticationProvider::Keycloak.create!(client_id: 'doctor', client_secret: 'tardis', realm: 'https://rh-sso.doctor.com/auth/realms/demo',
                                           account_type: AuthenticationProvider.account_types[:developer], account: @provider)
end

Given 'a developer portal auth0 integration' do
  @auth0_dev_portal_integration = AuthenticationProvider::Auth0.create!(client_id: 'doctor', client_secret: 'tardis', site: 'https://doctor.auth0.com',
                                        account_type: AuthenticationProvider.account_types[:developer], account: @provider)
end

Given 'a developer portal github integration' do
  AuthenticationProvider::GitHub.create!(client_id: 'doctor', client_secret: 'tardis', site: 'https://doctor.auth0.com',
                                        account_type: AuthenticationProvider.account_types[:developer], account: @provider)
end
