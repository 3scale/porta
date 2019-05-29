import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {HiddenServiceDiscoveryInput} from 'NewService/components/FormElements'

Enzyme.configure({adapter: new Adapter()})

it('should render itself properly', () => {
  const wrapper = mount(<HiddenServiceDiscoveryInput />)
  expect(wrapper.find('input').props().value).toEqual('discover')
  expect(wrapper.find('input').props().type).toEqual('hidden')
  expect(wrapper.find('input').props().name).toEqual('service[source]')
  expect(wrapper.find('input').props().id).toEqual('service_source')
})
