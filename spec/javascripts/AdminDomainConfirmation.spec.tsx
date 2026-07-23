import { mount } from 'enzyme'

import { AdminDomainConfirmation } from 'AdminDomainConfirmation/AdminDomainConfirmation'

const defaultProps = {
  isOpen: true,
  onConfirm: jest.fn(),
  onCancel: jest.fn()
}

const mountWrapper = (props: Partial<typeof defaultProps> = {}) =>
  mount(<AdminDomainConfirmation {...{ ...defaultProps, ...props }} />)

it('renders the modal when isOpen is true', () => {
  const wrapper = mountWrapper({ isOpen: true })
  expect(wrapper.exists('.pf-c-modal-box')).toBe(true)
})

it('does not render modal content when isOpen is false', () => {
  const wrapper = mountWrapper({ isOpen: false })
  expect(wrapper.exists('.pf-c-modal-box')).toBe(false)
})

it('calls onConfirm when the confirm button is clicked', () => {
  const onConfirm = jest.fn()
  const wrapper = mountWrapper({ onConfirm })
  wrapper.find('button.pf-m-primary').simulate('click')
  expect(onConfirm).toHaveBeenCalledTimes(1)
})

it('calls onCancel when the cancel button is clicked', () => {
  const onCancel = jest.fn()
  const wrapper = mountWrapper({ onCancel })
  wrapper.find('button.pf-m-link').simulate('click')
  expect(onCancel).toHaveBeenCalledTimes(1)
})

it('calls onCancel when the close (X) button is clicked', () => {
  const onCancel = jest.fn()
  const wrapper = mountWrapper({ onCancel })
  wrapper.find('button[aria-label="Close"]').simulate('click')
  expect(onCancel).toHaveBeenCalledTimes(1)
})

it('displays warning content about side effects', () => {
  const wrapper = mountWrapper()
  const text = wrapper.text()
  expect(text).toMatch(/SSL certificate/i)
  expect(text).toMatch(/Active sessions/i)
  expect(text).toMatch(/Email links/i)
  expect(text).toMatch(/Provider Admin SSO/i)
})
