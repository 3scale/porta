import { safeFromJsonString } from 'utilities/json-utils'

const store = window.localStorage
const key = (ident: string) => `toggle:${ident}`

/**
 * @param ident identifier for the storage
 * @returns returns state if it exists
 */
const load = function (ident: string): Record<string, boolean> | undefined {
  // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment -- FIXME: refactor to use getItem
  const value: string | null = store[key(ident)]
  return value ? safeFromJsonString<Record<string, boolean>>(value) : undefined
}

/**
 * @param ident identifier for the storage
 * @param state the whole state to be persisted
 */
const save = function (ident: string, state: unknown) {
  store[key(ident)] = JSON.stringify(state)
}

/**
 * @param ident identifier for the storage
 * @param changes { [className]: true/false }
 */
const update = function (ident: string, changes: Record<string, boolean>) {
  const current = load(ident)
  const updated = Object.assign({}, current, changes)

  save(ident, updated)
}

/**
 * @param ident identifier for the storage
 * @param currentClassName original class name
 * @param newClassName new class name
 */
export function moveState (ident: string, currentClassName: string, newClassName: string): void {
  const state = load(ident)
  if (state && typeof (state[newClassName]) === 'undefined') {
    state[newClassName] = state[currentClassName]
    // eslint-disable-next-line @typescript-eslint/no-dynamic-delete -- FIXME: The whole module needs refactor and cleanup
    delete state[currentClassName]
    save(ident, state)
  }
}

/**
 * @param ident identifier for the storage
 * @param classList element.classList
 */
export function recoverState (ident: string, classList: DOMTokenList, className: string): void {
  // eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing -- We don't trust these types so better not touch it.
  const storedState = load(ident) || { [className]: classList.contains(className) }
  const classState = typeof (storedState) === 'object' && storedState[className]

  if (typeof (classState) !== 'undefined') {
    classList.toggle(className, classState)
  }
}

/**
 * @param ident identifier for the storage
 * @param className element.classList FIXME: wrong param
 * @param value classList.toggle
 */
export function setState (ident: string, className: string, value: boolean): void {
  update(ident, { [className]: value })
}

/**
 * @param ident identifier for the storage
 * @param classList element.classList
 * @param className class to tbe toggled
 */
export function toggleState (ident: string, classList: DOMTokenList, className: string): void{
  // .toggle returns true/false depending if the class is there or not
  setState(ident, className, classList.toggle(className))
}

/**
 * @param ident identifier for the storage
 * @param classList element.classList
 * @param element Element that toggles
 * @param className class to be toggled
 */
export function toggle (ident: string, classList: DOMTokenList, element: Element, className: string): () => void {
  const handler = () => {
    toggleState(ident, classList, className)
    let event = undefined
    if (typeof Event === 'function') {
      event = new Event('resize')
    } else {
      event = document.createEvent('Event')
      event.initEvent('resize', true, true)
    }
    window.dispatchEvent(event)
  }

  recoverState(ident, classList, className)

  element.addEventListener('click', handler)

  return function () { element.removeEventListener('click', handler) }
}
