// TODO: Create React module for Integration Settings. Please.

import 'Settings/styles/authentication.scss'

const AUTH_WRAPPER_ID = 'auth-wrapper'
const AUTH_METHOD_CLASS = 'auth-method'
const AUTH_SETS_CLASS = 'auth-settings'
const AUTH_SETS_WRP_ID = 'auth-settings-wrapper'
const INTEGRATION_WRAPPER_ID = 'integration-wrapper'
const INTEGRATION_METHODS_CLASS = 'integration-method'
const SERVICE_MESH_ID = 'service_deployment_option_service_mesh_istio'
const APICAST_SETTINGS_CLASS = 'apicast-only-settings'
const OIDC_ID = 'service_proxy_authentication_method_oidc'

const toggleActive = (setting, active) => {
  setting.classList.toggle('hidden', active)
  setting.toggleAttribute('disabled', active)
}

export function initialize () {
  const authWrapper = document.getElementById(AUTH_WRAPPER_ID)
  const authSettingsWrapper = document.getElementById(AUTH_SETS_WRP_ID)
  const [...methods] = authWrapper.getElementsByClassName(AUTH_METHOD_CLASS)
  const [...settings] = authWrapper.getElementsByClassName(AUTH_SETS_CLASS)
  const [...integrations] = document.getElementById(INTEGRATION_WRAPPER_ID).getElementsByClassName(INTEGRATION_METHODS_CLASS)
  const [...apicastSettings] = document.getElementsByClassName(APICAST_SETTINGS_CLASS)
  const oidc = document.getElementById(OIDC_ID)
  const serviceMesh = document.getElementById(SERVICE_MESH_ID)

  methods.forEach(m => m.addEventListener('click', () => {
    toggleActive(authSettingsWrapper, serviceMesh.checked && !oidc.checked)
    settings.forEach(s => toggleActive(s, s.id !== `${m.id}_settings`))
  }))
  integrations.forEach(i => i.addEventListener('click', () => {
    apicastSettings.forEach(s => toggleActive(s, i.id === SERVICE_MESH_ID))
    toggleActive(authSettingsWrapper, i.id === SERVICE_MESH_ID && !oidc.checked)
  }))
}
