// @flow

export function initialize () {
  const tabs = document.querySelectorAll('label[for^="tab-"]')
  const inputs = document.querySelectorAll('input[name="apiap-tabs"]')

  inputs.forEach(i => i.addEventListener('change', toggleCurrentTab))

  function toggleCurrentTab () {
    tabs.forEach(tab => tab.classList.toggle('current-tab'))
  }
}
