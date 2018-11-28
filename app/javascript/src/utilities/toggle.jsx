'use strict'
import 'core-js/fn/string/includes'
import 'core-js/fn/symbol'
import 'core-js/fn/array/find'
import 'core-js/fn/array/iterator'
import 'core-js/fn/array/from'
import 'core-js/fn/object/assign' // make Object.assign on IE 11

const store = window.localStorage
const key = ident => `toggle:${ident}`

// @param {string} ident - identifier for the storage
// @return {undefined|object} - returns state if it exists
const load = function (ident) {
  let value = store[key(ident)]
  return value && JSON.parse(value)
}

// @param {string} ident - identifier for the storage
// @param {object} state - the whole state to be persisted
const save = function (ident, state) {
  store[key(ident)] = JSON.stringify(state)
}

// @param {string} ident - identifier for the storage
// @param {object} changes - { [className]: true/false }
const update = function (ident, changes) {
  let current = load(ident)
  let updated = Object.assign({}, current, changes)

  save(ident, updated)
}

// @param {string} ident - identifier for the storage
// @param {string} currentClassName - original class name
// @param {string} newClassName - new class name
export function moveState (ident, currentClassName, newClassName) {
  let state = load(ident)
  if (state && typeof (state[newClassName]) === 'undefined') {
    state[newClassName] = state[currentClassName]
    delete state[currentClassName]
    save(ident, state)
  }
}

// @param {string} ident - identifier for the storage
// @param {DOMTokenList} classList - element.classList
export function recoverState (ident, classList, className) {
  let storedState = load(ident) || { [className]: classList.contains(className) }
  let classState = typeof (storedState) === 'object' && storedState[className]

  if (typeof (classState) !== 'undefined') {
    classList.toggle(className, classState)
  }
}

// @param {string} ident - identifier for the storage
// @param {DOMTokenList} classList - element.classList
// @param {Boolean} value - classList.toggle
export function setState (ident, className, value) {
  update(ident, { [className]: value })
}

// @param {string} ident - identifier for the storage
// @param {DOMTokenList} classList - element.classList
// @param {string} className - class to be toggled
export function toggleState (ident, classList, className) {
  // .toggle returns true/false depending if the class is there or not
  setState(ident, className, classList.toggle(className))
}

// @param {string} ident - identifier for the storage
// @param {DOMTokenList} classList - element.classList
// @param {Element} toggle - Element that toggles
// @param {string} className - class to be toggled
export function toggle (ident, classList, toggle, className) {
  let handler = () => {
    toggleState(ident, classList, className)
    window.dispatchEvent(new Event('resize'))
  }

  recoverState(ident, classList, className)

  toggle.addEventListener('click', handler)

  return function () { toggle.removeEventListener('click', handler) }
}

export default toggle
