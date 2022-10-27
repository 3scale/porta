import { mount } from 'enzyme'

import { Spinner } from 'Common/components/Spinner'

import type { Props } from 'Common/components/Spinner'

const defaultProps: Props = {
  size: undefined,
  className: ''
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<Spinner {...{ ...defaultProps, ...props }} />)

afterEach(() => jest.resetAllMocks())

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists(Spinner)).toBe(true)
})
