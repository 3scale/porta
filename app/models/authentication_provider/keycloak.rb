class AuthenticationProvider::Keycloak < AuthenticationProvider
  self.authorization_scope = :iam_tools
  self.oauth_config_required = true

  validates :realm, presence: true
  validates :realm, format: { without: /\s/ }

  alias_attribute :realm, :site
end
