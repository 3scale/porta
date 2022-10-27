import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { DescriptionInput } from 'BackendApis/components/DescriptionInput'

import type { Props } from 'BackendApis/components/DescriptionInput'

const setDescription = jest.fn()

const defaultProps = {
  description: '',
  setDescription
} as const

const mountWrapper = (props: Partial<Props> = {}) => mount(<DescriptionInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should work', () => {
  const value = 'foo'
  const wrapper = mountWrapper()

  act(() => { wrapper.find(DescriptionInput).props().setDescription(value) })

  wrapper.update()
  expect(setDescription).toHaveBeenCalledWith(value)
})
