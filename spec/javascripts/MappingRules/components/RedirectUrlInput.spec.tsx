import { mount } from 'enzyme'

import { RedirectUrlInput, Props } from 'MappingRules/components/RedirectUrlInput'

const defaultProps = {
  redirectUrl: '',
  setRedirectUrl: jest.fn()
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<RedirectUrlInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
