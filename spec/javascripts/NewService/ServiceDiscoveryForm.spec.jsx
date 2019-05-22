import React from 'react'
import Enzyme, {shallow, mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {ServiceDiscoveryForm} from 'NewService'

Enzyme.configure({adapter: new Adapter()})

const props = {
  id: 'service_source',
  formActionPath: 'action-path',
  CSRFToken: null,
  HiddenServiceDiscoveryInput: null,
  submitText: 'Create Service',
  ListItems: null,
  ListItemsProps: {
  }
}

describe('Service Discovery Form', () => {
  it('should render properly', () => {
    const wrapper = shallow(<ServiceDiscoveryForm {...props}/>)
    expect(wrapper.find('#service_source').exists()).toEqual(true)
  })
  it('should not render error message by default', () => {
    const wrapper = mount(<ServiceDiscoveryForm {...props}/>)
    expect(wrapper.find('.errorMessage').exists()).toEqual(false)
  })
})
