// @flow

import React from 'react'

import { NameInput } from 'Applications'
import { render } from 'enzyme'

const props = {
  name: 'Name',
  setName: jest.fn()
}

it('should render', () => {
  const wrapper = render(<NameInput {...props} />)
  expect(wrapper.find('Name')).not.toBeNull()
})
