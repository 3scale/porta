import Keycloak from 'keycloak-js'

const keycloakConfig = {
  realm: process.env.REACT_APP_KEYCLOAK_REALM || '3scale',
  url: process.env.REACT_APP_KEYCLOAK_URL,
  'ssl-required': process.env.REACT_APP_KEYCLOAK_SSL,
  clientId: process.env.REACT_APP_KEYCLOAK_CLIENTID || 'portafly',
  'public-client': process.env.REACT_APP_KEYCLOAK_PUBLICK_CLIENT
}

const keycloak = Keycloak(keycloakConfig)
export { keycloak }
