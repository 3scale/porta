FactoryBot.define do

  factory(:authentication_provider) do
    sequence(:name) { |n| "name-#{n}" }
    sequence(:system_name) { |n| "system_name_#{n}" }
    association :account, factory: :simple_provider
    client_id 'A12345'
    client_secret 'Z9876'
    branding_state 'custom_branded'
    # token_url "http://example.com/oauth/token"
    # user_info_url "http://example.com/user_info"
    site 'http://example.com'
    kind 'github'
    account_type AuthenticationProvider.account_types[:developer]
  end

  factory(:self_authentication_provider, class: AuthenticationProvider::Auth0) do
    sequence(:name) { |n| "self-name-#{n}" }
    sequence(:system_name) { |n| "self-system_name_#{n}" }
    association :account, factory: :simple_provider
    client_id 'A12345'
    client_secret 'Z9876'
    branding_state 'custom_branded'
    # token_url "http://example.com/oauth/token"
    # user_info_url "http://example.com/user_info"
    site 'http://example.com'
    kind 'auth0'
    account_type AuthenticationProvider.account_types[:provider]
  end

  factory(:auth0_authentication_provider,
                    parent: :authentication_provider,
                    class: AuthenticationProvider::Auth0)

  factory(:github_authentication_provider,
                    parent: :authentication_provider,
                    class: AuthenticationProvider::GitHub) do
    branding_state 'threescale_branded'
  end

  factory(:keycloak_authentication_provider,
                    parent: :authentication_provider,
                    class: AuthenticationProvider::Keycloak) do
    kind 'keycloak'
  end

  factory(:redhat_customer_portal_authentication_provider,
                    parent: :authentication_provider,
                    class: AuthenticationProvider::RedhatCustomerPortal) do
    kind 'redhat_customer_portal'
  end
end
