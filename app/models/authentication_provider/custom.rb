class AuthenticationProvider::Custom < AuthenticationProvider
  self.authorization_scope = :iam_tools

  validates :site, format: { without: /\s/, message: :contains_whitespace }
end
