// @flow

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

export { openSelectWithModal, closeSelectWithModal }
