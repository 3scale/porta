import React from 'react'

import { render } from 'tests/custom-render'
import { Login } from 'pages'
import { useAuth } from 'auth'

jest.mock('auth')

it('should render the Login page', () => {
  (useAuth as jest.Mock).mockReturnValue({ authToken: null, setAuthToken: jest.fn() })
  const wrapper = render(<Login />)
  wrapper.debug()

  expect(wrapper.container.firstChild).toMatchSnapshot()
})

it('should not render when there is an auth token already', () => {
  (useAuth as jest.Mock).mockReturnValue({ authToken: 'le token', setAuthToken: jest.fn() })
  const wrapper = render(<Login />)
  wrapper.debug()

  expect(wrapper.container.firstChild).toMatchSnapshot()
})
