// @flow

import React from 'react'
import {mount, shallow} from 'enzyme'

import {Select} from 'NewService/components/FormElements'

const options = ['project_01', 'project_02']
const props = {
  name: 'my-select',
  id: 'select-id',
  options
}

it('should render itself properly', () => {
  const wrapper = mount(<Select {...props}/>)
  expect(wrapper.find(Select).exists()).toEqual(true)
})

it('should render a select with options', () => {
  const wrapper = mount(<Select {...props}/>)
  expect(wrapper.find('select').exists()).toEqual(true)

  for (let option of options) {
    expect(wrapper.exists(`option[value="${option}"]`)).toEqual(true)
  }
})

it('should call onChange when an option is selected', () => {
  const option = 'foo'
  const onChange = jest.fn()
  const wrapper = shallow(<Select {...props}/>)

  wrapper.setProps({ onChange })
  wrapper.find('select').simulate('change', option)

  expect(onChange).toHaveBeenCalledWith(option)
})
