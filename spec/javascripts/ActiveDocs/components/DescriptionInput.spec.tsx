import { mount } from 'enzyme'
import { FormGroup } from '@patternfly/react-core'

import { DescriptionInput } from 'ActiveDocs/components/DescriptionInput'

import type { Props } from 'ActiveDocs/components/DescriptionInput'

const defaultProps: Props = {
  description: '',
  setDescription: jest.fn()
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<DescriptionInput {... { ...defaultProps, ...props }} />)

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