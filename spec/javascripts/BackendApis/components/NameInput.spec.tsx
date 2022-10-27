import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'
import { TextInput } from '@patternfly/react-core'

import { NameInput } from 'BackendApis/components/NameInput'

import type { Props } from 'BackendApis/components/NameInput'

const setName = jest.fn()

const defaultProps = {
  name: '',
  setName
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<NameInput {...{ ...defaultProps, ...props }} />)

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
  const event = {} as React.FormEvent<HTMLInputElement>

  act(() => { wrapper.find(TextInput).props().onChange!(value, event) })

  wrapper.update()

  expect(setName).toHaveBeenCalledWith(value)
})
