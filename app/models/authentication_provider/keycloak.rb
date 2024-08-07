class AuthenticationProvider::Keycloak < AuthenticationProvider
  self.authorization_scope = :iam_tools
  self.oauth_config_required = true

  validates :realm, presence: true
  validates :realm, format: { with: URI.regexp(%w(http https)), message: :invalid_url }
  alias_attribute :realm, :site
end
