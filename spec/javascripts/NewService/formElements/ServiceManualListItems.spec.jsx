import React from 'react'
import {mount, shallow} from 'enzyme'

import {ServiceManualListItems} from 'NewService/components/FormElements'

it('should render itself', () => {
  const wrapper = mount(<ServiceManualListItems/>)
  expect(wrapper.find(ServiceManualListItems).exists()).toEqual(true)
})

it('should render all required forms', () => {
  const wrapper = shallow(<ServiceManualListItems/>)

  expect(wrapper.find('[id="service_name"][type="text"][name="service[name]"]').exists()).toBe(true)
  expect(wrapper.find('[id="service_system_name"][type="text"][name="service[system_name]"]').exists()).toBe(true)
  expect(wrapper.find('[id="service_description"][name="service[description]"]').exists()).toBe(true)
})
