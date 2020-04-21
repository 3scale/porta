import React from 'react'

import { render } from 'tests/custom-render'
import { Login } from 'pages'

it('should render the Login page', () => {
  const wrapper = render(<Login />)
  expect(wrapper.container.firstChild).toMatchSnapshot()
})
