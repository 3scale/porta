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
const PROXY_ENDPOINT_CLASS = 'proxy-endpoint'
const PROXY_ENDPOINTS_ID = 'proxy-endpoints'
const SELF_MANAGED = 'service_deployment_option_self_managed'

type ToggleFn = (active: boolean) => (setting: HTMLInputElement) => HTMLInputElement

export const toggle = (...toggleFns: ToggleFn[]): ToggleFn => (active) => (setting) => toggleFns.map(toggle => toggle(active)).reduce((s, t) => t(s), setting)

export const toggleAttrInSetting = (attr: string): ToggleFn => (active) => (setting) => {
  active ? setting.setAttribute(attr, attr) : setting.removeAttribute(attr)
  return setting
}

export const toggleHiddenClass: ToggleFn = (active: boolean) => (setting: HTMLInputElement) => {
  active ? setting.classList.add('hidden') : setting.classList.remove('hidden')
  return setting
}

export const toggleDisabled = toggleAttrInSetting('disabled')

export const toggleReadOnly = toggleAttrInSetting('readonly')

export const setValue = (el: HTMLInputElement, val: string) => {
  el.value = val
  return el
}

// FIXME: isReadOnly means the opposite!
export const setInputValue = (val: string) => (isReadOnly: boolean) => isReadOnly ? (setting: HTMLInputElement) => setValue(setting, val) : (setting: HTMLInputElement) => setting

// HACK: typescript doesn't infer the correct type when spreading HTMLCollectionOf<HTMLInputElement>. Try using Array.from() instead?
export function initialize () {
  const authWrapper = document.getElementById(AUTH_WRAPPER_ID) as HTMLInputElement
  const authSettingsWrapper = document.getElementById(AUTH_SETS_WRP_ID) as HTMLInputElement
  const [...methods] = authWrapper.getElementsByClassName(AUTH_METHOD_CLASS) as unknown as HTMLInputElement[]
  const [...settings] = authWrapper.getElementsByClassName(AUTH_SETS_CLASS) as unknown as HTMLInputElement[]
  const [...integrations] = (document.getElementById(INTEGRATION_WRAPPER_ID) as HTMLInputElement).getElementsByClassName(INTEGRATION_METHODS_CLASS) as unknown as HTMLInputElement[]
  const [...apicastSettings] = document.getElementsByClassName(APICAST_SETTINGS_CLASS) as unknown as HTMLInputElement[]
  const [...proxyEndpoints] = document.getElementsByClassName(PROXY_ENDPOINT_CLASS) as unknown as HTMLInputElement[]
  const apicastCustomUrl = (document.getElementById(PROXY_ENDPOINTS_ID) as HTMLInputElement).dataset.apicastCustomUrls === 'true'
  const oidc = document.getElementById(OIDC_ID) as HTMLInputElement
  const serviceMesh = document.getElementById(SERVICE_MESH_ID) as HTMLInputElement

  methods.forEach((m: HTMLInputElement) => m.addEventListener('click', () => {
    toggle(toggleDisabled, toggleHiddenClass)(serviceMesh && serviceMesh.checked && !oidc.checked)(authSettingsWrapper)
    settings.forEach((s: HTMLInputElement) => toggle(toggleDisabled, toggleHiddenClass)(s.id !== `${m.id}_settings`)(s))
  }))
  integrations.forEach(i => i.addEventListener('click', () => {
    apicastSettings.forEach((s: HTMLInputElement) => toggle(toggleDisabled, toggleHiddenClass)(i.id === SERVICE_MESH_ID)(s))
    proxyEndpoints.forEach((e: HTMLInputElement) => toggle(toggleReadOnly, setInputValue(e.dataset.default as string))(!apicastCustomUrl && i.id !== SELF_MANAGED)(e))
    toggle(toggleDisabled, toggleHiddenClass)(i.id === SERVICE_MESH_ID && !oidc.checked)(authSettingsWrapper)
  }))
}
