# frozen_string_literal: true

Given "the provider has the {authentication_provider} published" do |authentication_provider|
  @authentication_provider = authentication_provider
  @authentication_provider.update!(published: true)
end

Given "the Oauth2 user has all the required fields" do
  stub_user_data('OrganizationName')
end

Given "the Oauth2 user does not have all the required fields" do
  stub_user_data(nil)
end

When "I visit the {string} authentication provider page" do |name|
  visit path_to('the authentication providers page')
  click_on name
end

When "I visit the {string} authentication provider edit page" do |name|
  step %(I visit the #{name} authentication provider page)
  click_on 'Edit' if edit
end

def stub_user_data(org_name)
  attributes = {
    email: 'foo@3scale.localhost',
    email_verified: true,
    username: 'foo',
    org_name: org_name,
    kind:  @authentication_provider.kind,
    uid: 'alaska',
    id_token: 'idTokenForTests'
  }
  ThreeScale::OAuth2::ClientBase.any_instance.stubs(:authenticate!).returns(ThreeScale::OAuth2::UserData.new(attributes))
end
