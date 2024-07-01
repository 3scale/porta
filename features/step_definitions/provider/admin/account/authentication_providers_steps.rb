# frozen_string_literal: true

Given 'a single sign-on integration' do
  AuthenticationProvider::Keycloak.create!(client_id: 'doctor', client_secret: 'tardis', site: 'https://rh-sso.doctor.com/auth/realms/demo',
                                           account_type: AuthenticationProvider.account_types[:provider], account: @provider)
end
