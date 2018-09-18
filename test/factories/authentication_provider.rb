Factory.define(:authentication_provider) do |f|
  f.sequence(:name) { |n| "name-#{n}" }
  f.sequence(:system_name) { |n| "system_name_#{n}" }
  f.association :account, factory: :simple_provider
  f.client_id 'A12345'
  f.client_secret 'Z9876'
  f.branding_state 'custom_branded'
  # f.token_url "http://example.com/oauth/token"
  # f.user_info_url "http://example.com/user_info"
  f.site 'http://example.com'
  f.kind 'github'
  f.account_type AuthenticationProvider.account_types[:developer]
end

Factory.define(:self_authentication_provider, class: AuthenticationProvider::Auth0) do |f|
  f.sequence(:name) { |n| "self-name-#{n}" }
  f.sequence(:system_name) { |n| "self-system_name_#{n}" }
  f.association :account, factory: :simple_provider
  f.client_id 'A12345'
  f.client_secret 'Z9876'
  f.branding_state 'custom_branded'
  # f.token_url "http://example.com/oauth/token"
  # f.user_info_url "http://example.com/user_info"
  f.site 'http://example.com'
  f.kind 'auth0'
  f.account_type AuthenticationProvider.account_types[:provider]
end

Factory.define(:auth0_authentication_provider,
               parent: :authentication_provider,
               class: AuthenticationProvider::Auth0) do |f|
end

Factory.define(:github_authentication_provider,
               parent: :authentication_provider,
               class: AuthenticationProvider::GitHub) do |f|
  f.branding_state 'threescale_branded'
end

Factory.define(:keycloak_authentication_provider,
               parent: :authentication_provider,
               class: AuthenticationProvider::Keycloak) do |f|
  f.kind 'keycloak'
end

Factory.define(:redhat_customer_portal_authentication_provider,
               parent: :authentication_provider,
               class: AuthenticationProvider::RedhatCustomerPortal) do |f|
  f.kind 'redhat_customer_portal'
end
