import { mount } from 'enzyme'

import { BackendsWidget } from 'Dashboard/components/BackendsWidget'

import type { Props } from 'Dashboard/components/BackendsWidget'

const defaultProps = {
  newBackendPath: '',
  backendsPath: '',
  backends: []
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<BackendsWidget {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
