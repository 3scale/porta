/**
 * Include here any methods used in the test suite
 *
 * This is deliberately not included in utilities/index because it shouldn't be exported 'publicly' as a utility
 */

import type { ReactWrapper } from 'enzyme'

function selectOption<T> (wrapper: ReactWrapper<T>, name: string) {
  openSelect(wrapper)
  wrapper.find('.pf-c-select__menu-item')
    .findWhere(node => node.type() === 'button' && node.text() === name)
    .simulate('click')
}

function openSelect<T> (wrapper: ReactWrapper<T>) {
  wrapper.find('Select button.pf-c-select__toggle-button').simulate('click')
}

function openSelectWithModal<T> (wrapper: ReactWrapper<T>) {
  // HACK: suppress error logs during this step cause wrapping it inside act() makes the test fail
  jest.spyOn(console, 'error').mockImplementationOnce(() => '')

  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  wrapper.find('.pf-c-select__menu li button.pf-c-select__menu-item--sticky-footer').last().simulate('click')
}

function closeSelectWithModal<T> (wrapper: ReactWrapper<T>) {
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
  const location = { href: href, toString: () => href, replace: jest.fn() } as unknown as Location

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  delete (window as any).location
  window.location = location
}

/**
 * In a form, checks if the submit button is disabled
 * @param {ReactWrapper} wrapper - The enzyme react wrapper, must target a form
 * @return {boolean}
 */
function isSubmitDisabled<T> (wrapper: ReactWrapper<T>): boolean {
  return Boolean(wrapper.update().find('button.pf-m-primary[type="submit"]').prop('disabled'))
}

/**
 * Updates the value of an HTML input.
 * @param {ReactWrapper} wrapper - The enzyme react wrapper
 * @param {string} value - The text value to put in the input
 * @param {string | ReactWrapper | void} input - Can be either the input Node or a CSS selector. Otherwise the first input element found will be used.
 */
function updateInput<T> (
  wrapper: ReactWrapper<T>,
  value: string,
  input: string | ReactWrapper = 'input'
) {
  const _input = typeof input === 'string' ? wrapper.find(input).at(0) : input
  const node: HTMLInputElement = _input.getDOMNode()

  node.value = value
  _input.update()
  _input.simulate('change')
}

export {
  selectOption,
  openSelect,
  openSelectWithModal,
  closeSelectWithModal,
  mockLocation,
  isSubmitDisabled,
  updateInput
}
