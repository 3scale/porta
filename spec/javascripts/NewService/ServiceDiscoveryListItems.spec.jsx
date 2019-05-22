import React from 'react'
import Enzyme, {shallow} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {ServiceDiscoveryListItems} from 'NewService/components/FormElements'

Enzyme.configure({adapter: new Adapter()})

const props = {
  fetchServices: jest.fn(),
  projects: ['one', 'two'],
  services: ['three', 'four']
}

describe('Service Discovery List Items', () => {
  it('should render properly', () => {
    const wrapper = shallow(<ServiceDiscoveryListItems {...props}/>)
    expect(wrapper.find('#service_name_input').exists()).toEqual(true)
  })
})
