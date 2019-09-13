import React from 'react'
import { mount } from 'enzyme'

import { PolicyTile } from 'Policies/components/PolicyTile'

function setup (customProps = {}) {
  const defaultProps = {
    policy: {
      name: 'cors',
      humanName: 'CORS',
      summary: 'CORS policy',
      version: '1.0.0'
    },
    title: 'Das Politik',
    onClick: jest.fn()
  }
  const props = { ...defaultProps, ...customProps }
  const wrapper = mount(<PolicyTile {...props} />)

  return { props, wrapper }
}

it('should render itself correctly', () => {
  const {wrapper} = setup()
  expect(wrapper.find(PolicyTile).exists()).toBe(true)
  expect(wrapper.find('.Policy-name').text()).toBe('CORS')
  expect(wrapper.find('.Policy-version').text()).toBe('1.0.0')
  expect(wrapper.find('.Policy-summary').text()).toBe('CORS policy')
})

it('should render with the correct title', () => {
  const {wrapper} = setup({title: 'La Politique'})

  expect(wrapper.prop('title')).toBe('La Politique')
})

it('should have an onclick fn', () => {
  const {props, wrapper} = setup()
  wrapper.find('.Policy-article').simulate('click')
  expect(props.onClick.mock.calls.length).toBe(1)
})
