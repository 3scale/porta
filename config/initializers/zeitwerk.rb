Rails.autoloaders.main.inflector.inflect(
  'dsl' => 'DSL',
  'csrf' => 'CSRF',
  'sso' => 'SSO',
  'oauth2' => 'OAuth2',
  'provider_oauth2' => 'ProviderOAuth2',
  'find_oauth2_user_service' => 'FindOAuth2UserService',
  'oauth2_base' => 'OAuth2Base',
  'xml' => 'XML',
  'json_representer' => 'JSONRepresenter',
  'json_validator' => 'JSONValidator',
  'by_sso_token' => 'BySsoToken'
)

Rails.autoloaders.main.ignore(
  'app/lib/forum_support/deprecated/'
)
