import React from 'react'
import { render } from 'tests/custom-render'
import { AppHeaderTools } from 'components'
import { useAuth } from 'auth'

jest.mock('auth')

it('should render propertly', () => {
  (useAuth as jest.Mock).mockReturnValue({ userProfile: { firstName: 'Dooz', lastName: 'Kawa' } })
  const { getByText } = render(<AppHeaderTools />)

  expect(getByText('Dooz Kawa')).toBeInTheDocument()
})
