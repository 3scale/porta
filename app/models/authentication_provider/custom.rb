class AuthenticationProvider::Custom < AuthenticationProvider
  self.authorization_scope = :iam_tools
end
