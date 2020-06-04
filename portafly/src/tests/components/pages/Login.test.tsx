import React from 'react'

import { render } from 'tests/custom-render'
import { Login } from 'components/pages'
import { useAuth } from 'auth'
import { AuthToken } from 'types/auth'

jest.mock('auth')

function setup(authToken: AuthToken = null) {
  (useAuth as jest.Mock).mockReturnValue({ authToken, setAuthToken: jest.fn() })
  return render(<Login />)
}

it('should render the Login page when there is no token', () => {
  const { container } = setup()
  expect(container.querySelector('.pf-c-login')).toBeInTheDocument()
})

it('should not render when there is an auth token already', () => {
  const { container } = setup('le token')
  expect(container.querySelector('.pf-c-login')).not.toBeInTheDocument()
})
