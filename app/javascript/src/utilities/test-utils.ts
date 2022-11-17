/**
 * Include here any methods used in the test suite
 *
 * This is deliberately not included in utilities/index because it shouldn't be exported 'publicly' as a utility
 */

import type { ReactWrapper } from 'enzyme'

function selectOption (wrapper: ReactWrapper<unknown>, name: string): void {
  openSelect(wrapper)
  wrapper.find('.pf-c-select__menu-item')
    .findWhere(node => node.type() === 'button' && node.text() === name)
    .simulate('click')
}

function openSelect (wrapper: ReactWrapper<unknown>): void {
  wrapper.find('Select button.pf-c-select__toggle-button').simulate('click')
}

function openSelectWithModal (wrapper: ReactWrapper<unknown>): void {
  // HACK: This function should be called inside act(). However, that makes the test fail so suppress error logs instead.
  jest.spyOn(console, 'error').mockImplementationOnce(() => '')

  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  wrapper.find('.pf-c-select__menu li button.pf-c-select__menu-item--sticky-footer').last().simulate('click')
}

function closeSelectWithModal (wrapper: ReactWrapper<unknown>): void {
  wrapper.find('.pf-c-modal-box').find('.pf-c-button[aria-label="Close"]').simulate('click')
}

/**
 * Mocks window.location allowing to spy on URL changes.
 * Useful to test links, pagination, search... anything that expects an update to window.location
 *
 * @example
 * mockLocation('https://example.org')
 * expect(window.location).toEqual('https://example.org')
 * expect(window.location).toHaveBeenCalledWith(...)
 *
 * @param href The URL to be expected
 */
function mockLocation (href: string): void {
  const location = { href: href, toString: () => href, replace: jest.fn() } as unknown as Location

  // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-explicit-any -- HACK: need to delete location
  delete (window as any).location
  window.location = location
}

/**
 * In a form, checks if the submit button is disabled
 * @param wrapper - The enzyme react wrapper
 */
function isSubmitDisabled (wrapper: ReactWrapper<unknown>): boolean {
  return Boolean(wrapper.update().find('button.pf-m-primary[type="submit"]').prop('disabled'))
}

/**
 * Updates the value of an HTML input.
 * @param wrapper The enzyme react wrapper
 * @param value The text value to put in the input
 * @param selectorOrWrapper Can be either the input Node or a CSS selector. Otherwise the first input element found will be used.
 */
function updateInput (
  wrapper: ReactWrapper<unknown>,
  value: string,
  selectorOrWrapper: ReactWrapper | string = 'input'
): void {
  const input = typeof selectorOrWrapper === 'string' ? wrapper.find(selectorOrWrapper).at(0) : selectorOrWrapper
  const node: HTMLInputElement = input.getDOMNode()

  node.value = value
  input.update()
  input.simulate('change')
}

/**
 * Asserts existence (or absence) of a list of form group elements
 * TODO: should find based on input name: input[type="hidden"][name="${name}"]
 * @param wrapper The enzyme react wrapper
 * @param inputs Array of objects containing target ids and their presence
 */
function assertInputs (wrapper: ReactWrapper<unknown>, inputs: { id: string; present: boolean }[]): boolean {
  const formGroups = wrapper.find('.pf-c-form__group')
  return inputs.every(({ id, present }) => formGroups.exists(`[htmlFor="${id}"]`) == present)
}

export {
  selectOption,
  openSelect,
  openSelectWithModal,
  closeSelectWithModal,
  mockLocation,
  isSubmitDisabled,
  updateInput,
  assertInputs
}
