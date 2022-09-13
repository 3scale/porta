import React from 'react'
import { mount } from 'enzyme'

import { ToolbarSearch } from 'Common'

const defaultProps = {
  placeholder: ''
} as const

const mountWrapper = (props: undefined | {
  placeholder: string
}) => mount(<ToolbarSearch {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should have a placeholder', () => {
  const placeholder = 'Find something'
  const wrapper = mountWrapper({ placeholder })
  expect(wrapper.find(`input[placeholder="${placeholder}"]`).exists()).toBe(true)
})

it('should add more fields as children', () => {
  const wrapper = mount(
    <ToolbarSearch placeholder="">
      <input type="hidden" name="foo" value="bar" />
    </ToolbarSearch>
  )
  expect(wrapper.find('[name="foo"]').exists()).toBe(true)
})
