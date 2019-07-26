import React from 'react'
import Enzyme, {mount, shallow} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {ServiceManualListItems} from 'NewService/components/FormElements'

Enzyme.configure({adapter: new Adapter()})

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
