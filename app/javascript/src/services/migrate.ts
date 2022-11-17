import { setState } from 'utilities/toggle'

const store = window.localStorage
const key = 'cms-toggle-ids'

const getCookieByKey = function (cookieKey: string): string[] | undefined {
  const cookie = document.cookie.split(';')
  const data = cookie.find(c => c.includes(cookieKey))
  if (data) {
    return JSON.parse(decodeURIComponent(data.split('=')[1])) as string[]
  }
}

const alreadyMigrated = function () {
  return !!store[key]
}

const setAsMigrated = function () {
  store[key] = 'success'
}

// ident, classList, toggle, className
export function migrateDataToLocalStorage (ids: string[]): void {
  const services = document.querySelectorAll('.u-legacy-cookie')
  for (const wrapper of Array.from(services)) {
    if (!~ids.indexOf(wrapper.id)) {
      setState(wrapper.id, 'is-closed', false)
    }
  }
}

export function migrate (): void {
  if (!alreadyMigrated()) {
    const elementToMigrateIds = getCookieByKey(key)
    if (elementToMigrateIds) {
      migrateDataToLocalStorage(elementToMigrateIds)
      setAsMigrated()
    }
  }
}
