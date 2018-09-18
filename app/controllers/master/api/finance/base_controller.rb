# frozen_string_literal: true

class Master::Api::Finance::BaseController < Master::Api::BaseController
  include ApiAuthentication::ByAccessToken

  # TODO: It should be :finance instead of :account_management when master gets this permission for on-prem. See app/models/admin_section.rb:7
  self.access_token_scopes= :account_management
end
