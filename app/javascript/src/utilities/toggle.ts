'use strict'
import 'core-js/fn/string/includes'
import 'core-js/fn/symbol'
import 'core-js/fn/array/find'
import 'core-js/fn/array/iterator'
import 'core-js/fn/array/from'
import 'core-js/fn/object/assign' // make Object.assign on IE 11

const store = window.localStorage
const key = (ident: string) => `toggle:${ident}`

// @param {string} ident - identifier for the storage
// @return {undefined|object} - returns state if it exists
const load = function (ident: string) {
  const value = store[key(ident)]
  return value && JSON.parse(value)
}

// @param {string} ident - identifier for the storage
// @param {object} state - the whole state to be persisted
const save = function (ident: string, state: any) {
  store[key(ident)] = JSON.stringify(state)
}

// @param {string} ident - identifier for the storage
// @param {object} changes - { [className]: true/false }
const update = function (ident: string, changes: Record<any, any>) {
  const current = load(ident)
  const updated = Object.assign({}, current, changes)

  save(ident, updated)
}

// @param {string} ident - identifier for the storage
// @param {string} currentClassName - original class name
// @param {string} newClassName - new class name
export function moveState (ident: string, currentClassName: string, newClassName: string) {
  const state = load(ident)
  if (state && typeof (state[newClassName]) === 'undefined') {
    state[newClassName] = state[currentClassName]
    delete state[currentClassName]
    save(ident, state)
  }
}

// @param {string} ident - identifier for the storage
// @param {DOMTokenList} classList - element.classList
export function recoverState (ident: string, classList: DOMTokenList, className: string) {
  const storedState = load(ident) || { [className]: classList.contains(className) }
  const classState = typeof (storedState) === 'object' && storedState[className]

  if (typeof (classState) !== 'undefined') {
    // Toggle method second argument not supported in IE11
    if (classState) {
      classList.add(className)
    } else {
      classList.remove(className)
    }
  }
}

// @param {string} ident - identifier for the storage
// @param {DOMTokenList} classList - element.classList FIXME: wrong param
// @param {Boolean} value - classList.toggle
export function setState (ident: string, className: string, value: boolean) {
  update(ident, { [className]: value })
}

// @param {string} ident - identifier for the storage
// @param {DOMTokenList} classList - element.classList
// @param {string} className - class to be toggled
export function toggleState (ident: string, classList: DOMTokenList, className: string) {
  // .toggle returns true/false depending if the class is there or not
  setState(ident, className, classList.toggle(className))
}

// @param {string} ident - identifier for the storage
// @param {DOMTokenList} classList - element.classList
// @param {Element} toggle - Element that toggles
// @param {string} className - class to be toggled
export function toggle(ident: string, classList: DOMTokenList, toggle: Element, className: string): () => void {
  const handler = () => {
    toggleState(ident, classList, className)
    let event
    if (typeof Event === 'function') {
      event = new Event('resize')
    } else {
      event = document.createEvent('Event')
      event.initEvent('resize', true, true)
    }
    window.dispatchEvent(event)
  }

  recoverState(ident, classList, className)

  toggle.addEventListener('click', handler)

  return function () { toggle.removeEventListener('click', handler) }
}

export default toggle
