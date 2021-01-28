// @flow

import React from 'react'

import { DescriptionInput } from 'Applications'
import { render } from 'enzyme'

const props = {
  description: 'This is a description',
  setDescription: jest.fn()
}

it('should render', () => {
  const wrapper = render(<DescriptionInput {...props} />)
  expect(wrapper.find('This is a description')).not.toBeNull()
})
