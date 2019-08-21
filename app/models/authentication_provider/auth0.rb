class AuthenticationProvider::Auth0 < AuthenticationProvider
  self.authorization_scope = :iam_tools
  self.oauth_config_required = true

  validates :site, presence: true
  validates :site, format: { without: /\s/ }

end
