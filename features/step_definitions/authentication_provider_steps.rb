# frozen_string_literal: true

Given(/^the provider has the authentication provider "([^"]+)" published$/) do |authentication_provider_name|
  # Extracted from deleted transformer https://github.com/3scale/porta/blob/a5d6622d5a56bbda401f7d95e09b0ab19d05adba/features/support/transforms.rb#L233-L255
  authentication_provider = @provider.authentication_providers.find_by(name: authentication_provider_name)
  unless authentication_provider
    ap_underscored_name = authentication_provider_name.underscore
    options = OAUTH_PROVIDER_OPTIONS[ap_underscored_name.to_sym]
              .merge(
                {
                  system_name: "#{ap_underscored_name}_hex",
                  client_id: 'CLIENT_ID',
                  client_secret: 'CLIENT_SECRET',
                  kind: ap_underscored_name,
                  name: authentication_provider_name,
                  account_id: @provider.id,
                  identifier_key: 'id',
                  username_key: 'login',
                  trust_email: false
                }
              )

    authentication_provider_class = "AuthenticationProvider::#{authentication_provider_name}".constantize
    authentication_provider = authentication_provider_class.create(options)
  end
  @authentication_provider = authentication_provider
  @authentication_provider.update_attributes!(published: true)
end

Given(/^the Oauth2 user has all the required fields$/) do
  stub_user_data('OrganizationName')
end

Given(/^the Oauth2 user does not have all the required fields$/) do
  stub_user_data(nil)
end

When(/^I visit the "([^"]*)" authentication provider (edit )?page$/) do |name, edit|
  visit path_to('the authentication providers page')
  click_on name

  click_on 'Edit' if edit
end

def stub_user_data(org_name)
  attributes = {
    email: 'foo@3scale.localhost', email_verified: true, username: 'foo',
    org_name: org_name, kind:  @authentication_provider.kind,
    uid: 'alaska', id_token: 'idTokenForTests'
  }
  ThreeScale::OAuth2::ClientBase.any_instance.stubs(:authenticate!).returns(ThreeScale::OAuth2::UserData.new(attributes))
end
