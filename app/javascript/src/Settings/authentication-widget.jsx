import 'Settings/styles/authentication.scss'

const AUTH_WRAPPER_ID = 'auth-wrapper'
const AUTH_METHOD_CLASS = 'auth-method'
const AUTH_SETS_CLASS = 'auth-settings'
const INTEGRATION_WRAPPER_ID = 'integration-wrapper'
const INTEGRATION_METHODS_CLASS = 'integration-method'
const SERVICE_MESH_ID = 'service_deployment_option_service_mesh_istio'
const COMMON_SETTINGS_ID = 'common-settings'

const toggleActive = (setting, active) => {
  setting.classList.toggle('hidden', active)
  setting.toggleAttribute('disabled', active)
}

export function initialize () {
  const authWrapper = document.getElementById(AUTH_WRAPPER_ID)
  const [...methods] = authWrapper.getElementsByClassName(AUTH_METHOD_CLASS)
  const [...settings] = authWrapper.getElementsByClassName(AUTH_SETS_CLASS)
  const [...integrations] = document.getElementById(INTEGRATION_WRAPPER_ID).getElementsByClassName(INTEGRATION_METHODS_CLASS)
  const commonSettings = document.getElementById(COMMON_SETTINGS_ID)

  methods.forEach(m => m.addEventListener('click', () => settings.forEach(s => toggleActive(s, s.id !== `${m.id}_settings`))))
  integrations.forEach(i => i.addEventListener('click', () => toggleActive(commonSettings, i.id === SERVICE_MESH_ID)))
}
