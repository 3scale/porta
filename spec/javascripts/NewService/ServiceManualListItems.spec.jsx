import React from 'react'
import Enzyme, {shallow} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {ServiceManualListItems} from 'NewService/components/FormElements'

Enzyme.configure({adapter: new Adapter()})

describe('Service Manual List Items', () => {
  it('should render properly', () => {
    const wrapper = shallow(<ServiceManualListItems/>)
    expect(wrapper.find('#service_name_input').exists()).toEqual(true)
    expect(wrapper.find('#service_system_name_input').exists()).toEqual(true)
    expect(wrapper.find('#service_description_input').exists()).toEqual(true)
  })
})
