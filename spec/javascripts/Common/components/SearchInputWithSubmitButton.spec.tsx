import { mount } from 'enzyme'

import { SearchInputWithSubmitButton } from 'Common/components/SearchInputWithSubmitButton'

import type { Props } from 'Common/components/SearchInputWithSubmitButton'

const defaultProps = {
  placeholder: ''
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<SearchInputWithSubmitButton {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it('should have a placeholder', () => {
  const placeholder = 'Find something'
  const wrapper = mountWrapper({ placeholder })
  expect(wrapper.exists(`input[placeholder="${placeholder}"]`)).toEqual(true)
})
