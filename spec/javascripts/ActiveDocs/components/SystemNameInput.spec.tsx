import { mount } from 'enzyme'
import { FormGroup } from '@patternfly/react-core'

import { SystemNameInput } from 'ActiveDocs/components/SystemNameInput'

import type { Props } from 'ActiveDocs/components/SystemNameInput'

const defaultProps: Props = {
  systemName: '',
  setSystemName: jest.fn()
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<SystemNameInput {... { ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()

  expect(wrapper.exists()).toEqual(true)
})

it('should render an error', () => {
  const wrapper = mountWrapper({ errors: ['error'] })

  expect(wrapper.find(FormGroup).props().validated).toEqual('error')

  wrapper.setProps({ errors: [] })

  expect(wrapper.find(FormGroup).props().validated).toEqual('default')
})
