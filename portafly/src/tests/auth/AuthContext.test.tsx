import { AuthProvider, useAuth } from 'auth'
import * as React from 'react'
import { render, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'

const SamplePage = () => {
  const { authToken, setAuthToken } = useAuth()
  return (
    <>
      <input data-testid="login" onChange={(ev) => setAuthToken(ev.currentTarget.value)} />
      { authToken ? <p>Authenticated</p> : <p>Log in?</p> }
    </>
  )
}

const SampleApp = () => <AuthProvider><SamplePage /></AuthProvider>

test('should authenticate', () => {
  const { getByTestId, getByText } = render(<SampleApp />)
  const login = getByTestId('login')

  expect(getByText('Log in?')).toBeInTheDocument()

  fireEvent.change(login, { target: { value: 'LeToken' } })

  expect(getByText('Authenticated')).toBeInTheDocument()
})
