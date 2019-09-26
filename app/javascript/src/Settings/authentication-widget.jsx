import 'Settings/styles/authentication.scss'

const AUTH_WRAPPER_ID = 'auth-wrapper'
const AUTH_METHOD_CLASS = 'auth-method'
const AUTH_SETS_CLASS = 'auth-settings'

const toggleActive = (setting, active) => {
  setting.classList.toggle('hidden', active)
  setting.toggleAttribute('disabled', active)
}

export function initialize () {
  const wrapper = document.getElementById(AUTH_WRAPPER_ID)
  const [...methods] = wrapper.getElementsByClassName(AUTH_METHOD_CLASS)
  const [...settings] = wrapper.getElementsByClassName(AUTH_SETS_CLASS)

  methods.forEach(m => m.addEventListener('click', () => settings.forEach(s => toggleActive(s, s.id !== `${m.id}_settings`))))
}
