import 'core-js/fn/array/includes'
import 'core-js/fn/array/find'

import { setState } from 'utilities/toggle'

const store = window.localStorage
const key = 'cms-toggle-ids'

const getCookieByKey = function (cookieKey: string) {
  const cookie = document.cookie.split(';')
  const data = cookie.find(data => data.includes(cookieKey))
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
  const services = document.querySelectorAll('.u-legacy-cookie')
  for (const wrapper of Array.from(services)) {
    if (!~ids.indexOf(wrapper.id)) {
      setState(wrapper.id, 'is-closed', false)
    }
  }
}

export function migrate () {
  if (!alreadyMigrated()) {
    const elementToMigrateIds = getCookieByKey(key)
    if (elementToMigrateIds) {
      migrateDataToLocalStorage(elementToMigrateIds)
      setAsMigrated()
    }
  }
}

export default migrate
