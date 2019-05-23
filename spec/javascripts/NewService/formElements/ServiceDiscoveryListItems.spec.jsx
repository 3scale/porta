import React from 'react'
import Enzyme, {shallow} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {ServiceDiscoveryListItems} from 'NewService/components/FormElements'
import {Label, Select} from 'NewService/components/FormElements'

Enzyme.configure({adapter: new Adapter()})

const props = {
  fetchServices: jest.fn(),
  projects: ['one', 'two'],
  services: ['three', 'four']
}


it('should render itself', () => {
  const wrapper = shallow(<ServiceDiscoveryListItems {...props}/>)
  expect(wrapper.find('#service_name_input').exists()).toEqual(true)
})

it('should render two `Label` children', () => {
  const wrapper = shallow(<ServiceDiscoveryListItems {...props}/>)
  expect(wrapper.find(Label).length).toBe(2)
})

it('should render two `Select` children', () => {
  const wrapper = shallow(<ServiceDiscoveryListItems {...props}/>)
  expect(wrapper.find(Select).length).toBe(2)
})
