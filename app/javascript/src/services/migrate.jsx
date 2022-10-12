// @flow

import { setState } from 'utilities/toggle'

const store = window.localStorage
const key = 'cms-toggle-ids'

const getCookieByKey = function (cookieKey) {
  let cookie = document.cookie.split(';')
  let data = cookie.find(data => data.includes(cookieKey))
  if (data) {
    return JSON.parse(decodeURIComponent(data.split('=')[1]))
  }
}

const alreadyMigrated = function () {
  return !!store[key]
}

const setAsMigrated = function () {
  store[key] = 'success'
}

// ident, classList, toggle, className
export function migrateDataToLocalStorage (ids: string[]) {
  let services = document.querySelectorAll('.u-legacy-cookie')
  for (let wrapper of Array.from(services)) {
    if (!~ids.indexOf(wrapper.id)) {
      setState(wrapper.id, 'is-closed', false)
    }
  }
}

export function migrate () {
  if (!alreadyMigrated()) {
    let elementToMigrateIds = getCookieByKey(key)
    if (elementToMigrateIds) {
      migrateDataToLocalStorage(elementToMigrateIds)
      setAsMigrated()
    }
  }
}

export default migrate
