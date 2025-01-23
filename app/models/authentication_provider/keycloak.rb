class AuthenticationProvider::Keycloak < AuthenticationProvider
  self.authorization_scope = :iam_tools
  self.oauth_config_required = true

  validates :site, presence: true
  validates :site, format: { without: /\s/, message: :contains_whitespace }
  alias_attribute :realm, :site
end
