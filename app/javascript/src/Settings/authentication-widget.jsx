// TODO: Create React module for Integration Settings. Please.

const AUTH_WRAPPER_ID = 'auth-wrapper'
const AUTH_METHOD_CLASS = 'auth-method'
const AUTH_SETS_CLASS = 'auth-settings'
const AUTH_SETS_WRP_ID = 'auth-settings-wrapper'
const INTEGRATION_WRAPPER_ID = 'integration-wrapper'
const INTEGRATION_METHODS_CLASS = 'integration-method'
const SERVICE_MESH_ID = 'service_deployment_option_service_mesh_istio'
const APICAST_SETTINGS_CLASS = 'apicast-only-settings'
const OIDC_ID = 'service_proxy_authentication_method_oidc'
const PROXY_ENDPOINT_CLASS = 'proxy-endpoint'
const PROXY_ENDPOINTS_ID = 'proxy-endpoints'
const SELF_MANAGED = 'service_deployment_option_self_managed'

const toggle = (...toggleFns) => active => setting => toggleFns.map(toggle => toggle(active)).reduce((s, t) => t(s), setting)

const toggleAttrInSetting = (attr) => (active) => (setting) => {
  active ? setting.setAttribute(attr, attr) : setting.removeAttribute(attr)
  return setting
}

const toggleHiddenClass = (active) => (setting) => {
  active ? setting.classList.add('hidden') : setting.classList.remove('hidden')
  return setting
}

const toggleDisabled = toggleAttrInSetting('disabled')

const toggleReadOnly = toggleAttrInSetting('readonly')

const setValue = (el, val) => {
  el.value = val
  return el
}
const setInputValue = (val) => (isReadOnly) => isReadOnly ? setting => setValue(setting, val) : setting => setting

export function initialize () {
  const authWrapper = document.getElementById(AUTH_WRAPPER_ID)
  const authSettingsWrapper = document.getElementById(AUTH_SETS_WRP_ID)
  const [...methods] = authWrapper.getElementsByClassName(AUTH_METHOD_CLASS)
  const [...settings] = authWrapper.getElementsByClassName(AUTH_SETS_CLASS)
  const [...integrations] = document.getElementById(INTEGRATION_WRAPPER_ID).getElementsByClassName(INTEGRATION_METHODS_CLASS)
  const [...apicastSettings] = document.getElementsByClassName(APICAST_SETTINGS_CLASS)
  const [...proxyEndpoints] = document.getElementsByClassName(PROXY_ENDPOINT_CLASS)
  const apicastCustomUrl = document.getElementById(PROXY_ENDPOINTS_ID).dataset.apicastCustomUrls === 'true'
  const oidc = document.getElementById(OIDC_ID)
  const serviceMesh = document.getElementById(SERVICE_MESH_ID)

  methods.forEach(m => m.addEventListener('click', () => {
    toggle(toggleDisabled, toggleHiddenClass)(serviceMesh && serviceMesh.checked && !oidc.checked)(authSettingsWrapper)
    settings.forEach(s => toggle(toggleDisabled, toggleHiddenClass)(s.id !== `${m.id}_settings`)(s))
  }))
  integrations.forEach(i => i.addEventListener('click', () => {
    apicastSettings.forEach(s => toggle(toggleDisabled, toggleHiddenClass)(i.id === SERVICE_MESH_ID)(s))
    proxyEndpoints.forEach(e => toggle(toggleReadOnly, setInputValue(e.dataset.default))(!apicastCustomUrl && i.id !== SELF_MANAGED)(e))
    toggle(toggleDisabled, toggleHiddenClass)(i.id === SERVICE_MESH_ID && !oidc.checked)(authSettingsWrapper)
  }))
}
