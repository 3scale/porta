// @flow

/**
 * Include here any methods used in the test suite
 *
 * This is deliberately not included in utilities/index because it shouldn't be exported 'publicly' as a utility
 */

import type { ReactWrapper } from 'enzyme'

function openSelectWithModal <T> (wrapper: ReactWrapper<T>) {
  // HACK: suppress error logs during this step cause wrapping it inside act() makes the test fail
  const spy = jest.spyOn(console, 'error')
  spy.mockImplementation(() => {})

  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  wrapper.find('.pf-c-select__menu li button.pf-c-select__menu-item--sticky-footer').last().simulate('click')

  spy.mockClear()
}

function closeSelectWithModal <T> (wrapper: ReactWrapper<T>) {
  wrapper.find(`.pf-c-modal-box`).find('.pf-c-button[aria-label="Close"]').simulate('click')
}

/**
 * Mocks window.location allowing to spy on URL changes.
 * Useful to test links, pagination, search... anything that expects an update to window.location
 *
 * @example
 * mockLocation('https://example.org)
 * expect(window.location).toHaveBeenCalledWith(...)
 * @param {string} href - the URL to be expected
 */
function mockLocation (href: string) {
  delete window.location
  const location: Location = (new URL(href): any) // emulates Location object
  // $FlowIgnore[cannot-write] yes we can
  location.replace = jest.fn()
  window.location = location
}

/**
 * Updates the value of an HTML input.
 * @param {ReactWrapper} wrapper - The enzyme react wrapper
 * @param {string} value - The text value to put in the input
 * @param {string | ReactWrapper | void} input - Can be either the input Node or a CSS selector. Otherwise the first input element found will be used.
 */
function updateInput <T> (wrapper: ReactWrapper<T>, value: string, input?: string | ReactWrapper<any> = 'input') {
  const _input = typeof input === 'string' ? wrapper.find(input).at(0) : input
  // $FlowIgnore[incompatible-type]
  const node: HTMLInputElement = _input.getDOMNode()

  node.value = value
  _input.update()
  _input.simulate('change')
}

export { openSelectWithModal, closeSelectWithModal, mockLocation, updateInput }
