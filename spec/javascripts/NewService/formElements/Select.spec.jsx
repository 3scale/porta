import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {Select} from 'NewService/components/FormElements'

Enzyme.configure({adapter: new Adapter()})

const props = {
  name: 'my-select',
  id: 'select-id',
  onChange: jest.fn(),
  options: [
    {metadata: {name: 'one'}},
    {metadata: {name: 'two'}}
  ]
}

it('should render itself properly', () => {
  const wrapper = mount(<Select {...props}/>)
  expect(wrapper.find('select').exists()).toEqual(true)
  expect(wrapper.find('select').props().name).toEqual('my-select')
  expect(wrapper.find('select').props().id).toEqual('select-id')
  expect(wrapper.find('select').props().onChange).toEqual(props.onChange)
})

it('should render with proper options', () => {
  const wrapper = mount(<Select {...props}/>)
  expect(wrapper.find('option').length).toEqual(2)
  expect(wrapper.find('option').first().props().value).toEqual('one')
  expect(wrapper.find('option').last().props().value).toEqual('two')
})
