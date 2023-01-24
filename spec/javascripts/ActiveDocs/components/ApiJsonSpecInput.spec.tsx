import { mount } from 'enzyme'
import { FormGroup } from '@patternfly/react-core'

import { ApiJsonSpecInput } from 'ActiveDocs/components/ApiJsonSpecInput'

import type { Props } from 'ActiveDocs/components/ApiJsonSpecInput'

const mockMirror = {
  fromTextArea: () => {
    return {
      setValue: jest.fn(),
      on: jest.fn()
    }
  }
}

// @ts-expect-error Mocking CodeMirror
window.CodeMirror = mockMirror

const setApiJsonSpec = jest.fn()

const defaultProps: Props = {
  apiJsonSpec: '',
  setApiJsonSpec
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ApiJsonSpecInput {... { ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()

  expect(wrapper.exists()).toEqual(true)
})

it('should render an error', () => {
  const wrapper = mountWrapper({ errors: ["can't be blank"] })

  expect(wrapper.find(FormGroup).props().validated).toEqual('error')

  wrapper.setProps({ errors: [] })

  expect(wrapper.find(FormGroup).props().validated).toEqual('default')
})

it('should be required', () => {
  const wrapper = mountWrapper()

  expect(wrapper.find(FormGroup).props().isRequired).toEqual(true)
})
