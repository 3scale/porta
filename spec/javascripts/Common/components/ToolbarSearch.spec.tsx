import { mount } from 'enzyme'

import { ToolbarSearch } from 'Common/components/ToolbarSearch'

import type { Props } from 'Common/components/ToolbarSearch'

const defaultProps = {
  placeholder: ''
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ToolbarSearch {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it('should have a placeholder', () => {
  const placeholder = 'Find something'
  const wrapper = mountWrapper({ placeholder })
  expect(wrapper.exists(`input[placeholder="${placeholder}"]`)).toEqual(true)
})

it('should add more fields as children', () => {
  const wrapper = mount(
    <ToolbarSearch placeholder="">
      <input name="foo" type="hidden" value="bar" />
    </ToolbarSearch>
  )
  expect(wrapper.exists('[name="foo"]')).toEqual(true)
})
