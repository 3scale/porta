# frozen_string_literal: true

# Example:
#
#   Given a provider
#   And the provider has the following access tokens:
#     | Name    | Scopes                     | Permission |
#     | LeToken | Billing API, Analytics API | Read Only  |
#
Given "{provider} has the following access tokens:" do |provider, table|
  transform_access_tokens_table(table)

  table.hashes.each do |options|
    @access_token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, **options)
  end
end
