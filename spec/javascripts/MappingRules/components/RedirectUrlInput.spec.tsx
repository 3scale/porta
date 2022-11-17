import { mount } from 'enzyme'

import { RedirectUrlInput } from 'MappingRules/components/RedirectUrlInput'

import type { Props } from 'MappingRules/components/RedirectUrlInput'

const defaultProps = {
  redirectUrl: '',
  setRedirectUrl: jest.fn()
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<RedirectUrlInput {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})
