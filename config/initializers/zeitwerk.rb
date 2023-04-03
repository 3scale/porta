Rails.autoloaders.main.inflector.inflect(
  'dsl' => 'DSL',
  'csrf' => 'CSRF',
  'sso' => 'SSO',
  'oauth2' => 'OAuth2',
  'oauth2_base' => 'OAuth2Base',
  'xml' => 'XML',
  'json_representer' => 'JSONRepresenter',
  'json_validator' => 'JSONValidator',
  'by_sso_token' => 'BySsoToken'
)

Rails.autoloaders.main.ignore(
  'app/lib/forum_support/deprecated/'
)
