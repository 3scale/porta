import React from 'react'
import Enzyme, {shallow} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {ServiceManualForm} from 'NewService'

Enzyme.configure({adapter: new Adapter()})

const props = {
  id: 'new_service',
  formActionPath: 'action-path',
  CSRFToken: null,
  submitText: 'Add API',
  ListItems: null
}

describe('Service Manual Form', () => {
  it('should render properly', () => {
    const wrapper = shallow(<ServiceManualForm {...props}/>)
    expect(wrapper.find('#new_service').exists()).toEqual(true)
  })
})
