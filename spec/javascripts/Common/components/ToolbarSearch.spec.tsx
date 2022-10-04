import { mount } from 'enzyme'
import { ToolbarSearch } from 'Common/components/ToolbarSearch'

import type { Props } from 'Common/components/ToolbarSearch'

const defaultProps = {
  placeholder: ''
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ToolbarSearch {...{ ...defaultProps, ...props }} />)

afterEach(() => jest.resetAllMocks())

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
      <input name="foo" type="hidden" value="bar" />
    </ToolbarSearch>
  )
  expect(wrapper.find('[name="foo"]').exists()).toBe(true)
})
