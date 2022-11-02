import { mount, shallow } from 'enzyme'

import { ServiceManualForm } from 'NewService/components/ServiceManualForm'
import { ServiceManualListItems } from 'NewService/components/FormElements/ServiceManualListItems'
import { FormWrapper } from 'NewService/components/FormElements/FormWrapper'

import type { Props } from 'NewService/components/ServiceManualForm'

const props: Props = {
  backendApis: [],
  template: {
    service: {
      name: 'New API',
      system_name: 'new_api',
      description: 'A brand new API'
    },
    errors: {}
  },
  formActionPath: 'action-path'
}

it('should render itself', () => {
  const wrapper = shallow(<ServiceManualForm {...props} />)
  const form = wrapper.find('#new_service')
  expect(form.exists()).toEqual(true)
  expect(form.prop('formActionPath')).toEqual('action-path')
})

it('should render `FormWrapper` child', () => {
  const wrapper = mount(<ServiceManualForm {...props} />)
  expect(wrapper.exists(FormWrapper)).toEqual(true)
})

it('should render `ServiceManualListItems` child', () => {
  const wrapper = mount(<ServiceManualForm {...props} />)
  expect(wrapper.exists(ServiceManualListItems)).toEqual(true)
})
