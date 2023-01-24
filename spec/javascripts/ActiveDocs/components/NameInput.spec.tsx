import { mount } from 'enzyme'
import { FormGroup } from '@patternfly/react-core'

import { NameInput } from 'ActiveDocs/components/NameInput'

import type { Props } from 'ActiveDocs/components/NameInput'

const defaultProps: Props = {
  name: '',
  setName: jest.fn()
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<NameInput {... { ...defaultProps, ...props }} />)

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
