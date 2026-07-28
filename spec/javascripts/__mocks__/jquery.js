// This mock exists because Stats source files use jQuery as an event bus and for DOM manipulation.
// It should be removed when Stats is refactored to use native APIs instead of jQuery.
//
// The WeakMap cache ensures $(obj) returns the same instance for the same object, so that
// jest.spyOn($(obj), 'method') works across calls.

const cache = new WeakMap()

const jQueryMock = (selector) => {
  const el = typeof selector === 'string' ? document.querySelector(selector) : selector

  if (el && cache.has(el)) return cache.get(el)

  const instance = {
    on: () => instance,
    trigger: () => instance,
    triggerHandler: () => instance,
    val: () => el?.value ?? '',
    datepicker: () => instance,
    find: (s) => jQueryMock(el?.querySelector(s)),
    toggleClass: () => instance,
    html: (content) => {
      if (el && content !== undefined) el.innerHTML = typeof content === 'string' ? content : ''
      return instance
    },
    append: (child) => {
      if (el && child) el.appendChild(child instanceof Node ? child : document.createTextNode(String(child)))
      return instance
    },
    0: el,
    length: el ? 1 : 0
  }

  if (el) cache.set(el, instance)
  return instance
}

jQueryMock.getJSON = () => ({ done: () => ({ fail: () => {} }) })

module.exports = jQueryMock
module.exports.default = jQueryMock
