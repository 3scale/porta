import { mount } from 'enzyme'

import { AuthenticationProvidersEmptyState } from 'AuthenticationProviders/components/AuthenticationProvidersEmptyState'

import type { Props } from 'AuthenticationProviders/components/AuthenticationProvidersEmptyState'

const defaultProps = {
  newHref: '/new'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<AuthenticationProvidersEmptyState {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()

  expect(wrapper.exists()).toEqual(true)
})
