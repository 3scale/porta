import { mount } from 'enzyme'
import { HttpMethodSelect } from 'MappingRules/components/HttpMethodSelect'

import type { Props } from 'MappingRules/components/HttpMethodSelect'

const defaultProps = {
  httpMethod: 'GET',
  httpMethods: ['GET', 'POST'],
  setHttpMethod: jest.fn()
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<HttpMethodSelect {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
