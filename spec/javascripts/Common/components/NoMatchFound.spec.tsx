import { mount } from 'enzyme'
import { Button } from '@patternfly/react-core'

import { NoMatchFound } from 'Common/components/NoMatchFound'

import type { Props } from 'Common/components/NoMatchFound'

const defaultProps = {
  onClearFiltersClick: undefined
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<NoMatchFound {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it('should not render a button', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists(Button)).toEqual(false)
})

describe('with an All Filter Clear button', () => {
  const onClearFiltersClick = jest.fn()
  const props = { onClearFiltersClick }

  afterEach(() => onClearFiltersClick.mockReset())

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
