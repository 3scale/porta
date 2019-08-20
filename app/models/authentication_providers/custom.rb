# frozen_string_literal: true

class AuthenticationProviders::Custom < AuthenticationProvider
  self.authorization_scope = :iam_tools
end
