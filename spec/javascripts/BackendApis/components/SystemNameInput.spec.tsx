import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { SystemNameInput } from 'BackendApis/components/SystemNameInput'

import type { Props } from 'BackendApis/components/SystemNameInput'

const setSystemName = jest.fn()

const defaultProps = {
  systemName: '',
  setSystemName
} as const

const mountWrapper = (props: Partial<Props> = {}) => mount(<SystemNameInput {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it('should work', () => {
  const value = 'foo'
  const wrapper = mountWrapper()

  act(() => { wrapper.find(SystemNameInput).props().setSystemName(value) })

  wrapper.update()
  expect(setSystemName).toHaveBeenCalledWith(value)
})
