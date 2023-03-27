import type { FieldCatalogProps, FieldGroupProps, LegendCollectionProps, TypeItemProps } from 'Settings/types'
import type { Props } from './components/Form'

const INTEGRATION_METHOD_DEFAULTS: FieldCatalogProps & FieldGroupProps = {
  value: 'hosted',
  name: 'deployment_option',
  label: '',
  catalog: {
    hosted: 'APIcast 3scale managed',
    // eslint-disable-next-line @typescript-eslint/naming-convention
    self_managed: 'APIcast self-managed',
    // eslint-disable-next-line @typescript-eslint/naming-convention
    service_mesh_istio: 'Istio'
  }
}

const AUTHENTICATION_METHOD_DEFAULTS: FieldCatalogProps & FieldGroupProps = {
  value: '1',
  name: 'proxy_authentication_method',
  label: '',
  catalog: {
    // eslint-disable-next-line @typescript-eslint/naming-convention
    '1': 'API Key (user_key)',
    // eslint-disable-next-line @typescript-eslint/naming-convention
    '2': 'App_ID and App_Key Pair',
    oidc: 'OpenID Connect'
  }
}

const PROXY_ENDPOINTS_DEFAULTS: FieldGroupProps[] = [
  {
    defaultValue: 'https://api-2.staging.apicast.com',
    placeholder: 'https://api.provider-name.com',
    label: 'Staging Public Base URL',
    name: 'sandbox_endpoint',
    hint: 'Public address of your API gateway in the staging environment.',
    value: 'https://custom.api.staging.provider-name.com',
    inputType: 'url'
  },
  {
    defaultValue: 'https://api-2.apicast.com',
    placeholder: 'https://api.provider-name.com',
    label: 'Staging Public Base URL',
    name: 'endpoint',
    hint: 'Public address of your API gateway in the production environment.',
    value: 'https://custom.api.provider-name.com',
    inputType: 'url'
  }
]

const API_KEY_SETTINGS_DEFAULT: FieldGroupProps = {
  label: 'Auth user key',
  name: 'auth_user_key',
  value: 'user_key'
}

const APP_ID_KEY_PAIR_SETTINGS_DEFAULT: FieldGroupProps[] = [
  {
    label: 'App ID parameter',
    name: 'auth_app_id',
    hint: 'Public address of your API gateway in the staging environment.',
    value: 'app_id'
  },
  {
    label: 'App Key parameter',
    name: 'auth_app_key',
    value: 'app_key'
  }
]

const OIDC_BASICS_SETTINGS_DEFAULTS: TypeItemProps = {
  type: {
    value: 'keycloak',
    name: 'oidc_issuer_type',
    label: 'OpenID Connect Issuer Type',
    catalog: {
      keycloak: 'Red Hat Single Sign-On',
      rest: 'REST API'
    }
  },
  item: {
    value: '',
    name: 'oidc_issuer_endpoint',
    label: 'OpenID Connect Issuer',
    placeholder: 'https://sso.example.com/auth/realms/gateway',
    hint: 'Location of your OpenID Provider. The format of this endpoint is determined on your OpenID Provider setup. A common guidance would be "https://CLIENT_ID:CLIENT_SECRET@HOST:PORT/auth/realms/REALM_NAME".'
  }
}

const OIDC_FLOW_SETTINGS_DEFAULTS: FieldGroupProps[] = [
  { name: 'service_accounts_enabled', label: 'Service Accounts Flow', checked: false },
  { name: 'standard_flow_enabled', label: 'Authorization Code Flow', checked: false },
  { name: 'implicit_flow_enabled', label: 'Implicit Flow', checked: false },
  { name: 'direct_access_grants_enabled', label: 'Direct Access Grant Flow', checked: false }
] as FieldGroupProps[] // Hack: value is required string, however it is not in the defaults... We need to check this before making it optional or adding empty string '' to the defaults.

const OIDC_JWT_SETTINGS_DEFAULTS: TypeItemProps = {
  type: {
    value: 'plain',
    name: 'jwt_claim_with_client_id_type',
    label: 'ClientID Token Claim Type',
    hint: 'Process the ClientID Token Claim value as a string or as a liquid template. When set to "Liquid" you can define more complex rules. e.g. If "some_claim" is an array you can select the first value this like {{ some_claim | first }}.',
    catalog: {
      plain: 'plain',
      liquid: 'liquid'
    }
  },
  item: {
    value: 'azp',
    name: 'jwt_claim_with_client_id',
    label: 'ClientID Token Claim',
    placeholder: 'azp',
    hint: 'The Token Claim that contains the clientID. Defaults to "azp".'
  }
}

const OIDC_SETTINGS_DEFAULTS = {
  basicSettings: OIDC_BASICS_SETTINGS_DEFAULTS,
  flowSettings: OIDC_FLOW_SETTINGS_DEFAULTS,
  jwtSettings: OIDC_JWT_SETTINGS_DEFAULTS
}

const CREDENTIALS_LOCATION_DEFAULTS: FieldCatalogProps & FieldGroupProps = {
  value: 'headers',
  name: 'credentials_location',
  label: '',
  catalog: {
    headers: 'As HTTP Headers',
    query: 'As query parameters (GET) or body parameters (POST/PUT/DELETE)',
    authorization: 'As HTTP Basic Authentication'
  }
}

const SECURITY_DEFAULTS: FieldGroupProps[] = [
  {
    defaultValue: '',
    placeholder: 'https://api.provider-name.com',
    label: 'Host Header',
    name: 'hostname_rewrite',
    hint: 'Lets you define a custom Host request header. This is needed if your API backend only accepts traffic from a specific host.',
    value: '',
    readOnly: false
  },
  {
    defaultValue: '',
    placeholder: 'https://api.provider-name.com',
    label: 'Secret Token',
    name: 'secret_token',
    hint: 'Enables you to block any direct developer requests to your API backend; each 3scale API gateway call to your API backend contains a request header called X-3scale-proxy-secret-token. The value of this header can be set by you here. It\'s up to you ensure your backend only allows calls with this secret header.',
    value: '',
    readOnly: false
  }
]

const GATEWAY_RESPONSE_DEFAULT: LegendCollectionProps[] = [
  {
    legend: 'Authentication Failed Error',
    collection: [
      {
        label: 'Response Code',
        name: 'error_status_auth_failed',
        value: '403',
        inputType: 'number'
      },
      {
        label: 'Content-type',
        name: 'error_headers_auth_failed',
        value: 'text/plain; charset=us-ascii',
        inputType: 'text'
      },
      {
        label: 'Response Body',
        name: 'error_auth_failed',
        value: 'Authentication failed',
        inputType: 'text'
      }
    ]
  },
  {
    legend: 'Authentication Missing Error',
    collection: [
      {
        label: 'Response Code',
        name: 'error_status_auth_missing',
        value: '403',
        inputType: 'number'
      },
      {
        label: 'Content-type',
        name: 'error_headers_auth_missing',
        value: 'text/plain; charset=us-ascii',
        inputType: 'text'
      },
      {
        label: 'Response Body',
        name: 'error_auth_missing',
        value: 'Authentication parameters missing',
        inputType: 'text'
      }
    ]
  },
  {
    legend: 'Match Error',
    collection: [
      {
        label: 'Response Code',
        name: 'error_status_no_match',
        value: '404',
        inputType: 'number'
      },
      {
        label: 'Content-type',
        name: 'error_headers_no_match',
        value: 'text/plain; charset=us-ascii',
        inputType: 'text'
      },
      {
        label: 'Response Body',
        name: 'error_no_match',
        value: 'No Mapping Rule matched',
        inputType: 'text'
      }
    ]
  },
  {
    legend: 'Usage limit exceeded error',
    collection: [
      {
        label: 'Response Code',
        name: 'error_status_limits_exceeded',
        value: '429',
        inputType: 'number'
      },
      {
        label: 'Content-type',
        name: 'error_headers_limits_exceeded',
        value: 'text/plain; charset=us-ascii',
        inputType: 'text'
      },
      {
        label: 'Response Body',
        name: 'error_limits_exceeded',
        value: 'Usage limit exceeded',
        inputType: 'text'
      }
    ]
  }
]

const AUTHENTICATION_SETTINGS_DEFAULT = {
  oidcSettings: OIDC_SETTINGS_DEFAULTS,
  appIdKeyPairSettings: APP_ID_KEY_PAIR_SETTINGS_DEFAULT,
  apiKeySettings: API_KEY_SETTINGS_DEFAULT
}

const SETTINGS_DEFAULT: Props = {
  isProxyCustomUrlActive: false,
  integrationMethod: INTEGRATION_METHOD_DEFAULTS,
  authenticationMethod: AUTHENTICATION_METHOD_DEFAULTS,
  proxyEndpoints: PROXY_ENDPOINTS_DEFAULTS,
  authenticationSettings: AUTHENTICATION_SETTINGS_DEFAULT,
  credentialsLocation: CREDENTIALS_LOCATION_DEFAULTS,
  security: SECURITY_DEFAULTS,
  gatewayResponse: GATEWAY_RESPONSE_DEFAULT
}

export {
  INTEGRATION_METHOD_DEFAULTS,
  PROXY_ENDPOINTS_DEFAULTS,
  AUTHENTICATION_METHOD_DEFAULTS,
  AUTHENTICATION_SETTINGS_DEFAULT,
  OIDC_SETTINGS_DEFAULTS,
  SETTINGS_DEFAULT
}
