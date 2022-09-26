import React from 'react'
import { mount } from 'enzyme'

import { PolicyTile, Props } from 'Policies/components/PolicyTile'

const defaultProps: Props = {
  policy: {
    $schema: '',
    name: 'apicast',
    humanName: 'Apicast',
    summary: 'Apicast summary',
    description: ['Apicast description'],
    version: '1.0.0',
    configuration: {}
  },
  onClick: jest.fn(),
  title: undefined
}

it('should render', () => {
  const wrapper = mount(<PolicyTile {...defaultProps} />)
  expect(wrapper.exists()).toEqual(true)
})
