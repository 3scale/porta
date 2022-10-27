import { mount } from 'enzyme'
import { Button } from '@patternfly/react-core'

import { NoMatchFound } from 'Common/components/NoMatchFound'

import type { Props } from 'Common/components/NoMatchFound'

const onClearFiltersClick = jest.fn()
const defaultProps = {}

const mountWrapper = (props: Partial<Props> = {}) => mount(<NoMatchFound {...{ ...defaultProps, ...props }} />)

afterEach(() => jest.resetAllMocks())

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should not render a button', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists(Button)).toBe(false)
})

describe('with an All Filter Clear button', () => {
  const props = { onClearFiltersClick }

  it('should render a button', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find(Button).text()).toEqual('Clear all filters')
  })

  it('should invoke the callback', () => {
    const wrapper = mountWrapper(props)
    wrapper.find(Button).simulate('click')
    expect(onClearFiltersClick).toHaveBeenCalledTimes(1)
  })
})
