/* eslint-disable no-console */
import { AuthProvider, useAuth } from 'auth'
import * as React from 'react'
import { render, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { KeycloakInstance } from 'keycloak-js'

const keycloak = {
  token: 'LeSuperSecretToken',
  logout: jest.fn()
}
const profile = {
  firstName: 'Coco',
  lastName: 'Loco'
}

const SamplePage = () => {
  const { authToken, userProfile, logout } = useAuth()

  return (
    <>
      { authToken
        ? (
          <p data-testid="user">
            {`${userProfile.firstName} ${userProfile.lastName} is logged in`}
            <button data-testid="logoutbutton" type="button" onClick={logout}>logout</button>
          </p>
        )
        : <p>Log in?</p> }
    </>
  )
}

const SampleApp = () => (
  <AuthProvider
    userProfile={profile}
    keycloak={keycloak as unknown as KeycloakInstance}
  >
    <SamplePage />
  </AuthProvider>
)

test('should display the user profile data when logged in', () => {
  const { getByText } = render(<SampleApp />)

  expect(getByText('Coco Loco is logged in')).toBeInTheDocument()
})

test('should provide a log out function', () => {
  const { getByTestId } = render(<SampleApp />)
  const logoutButton = getByTestId('logoutbutton')

  fireEvent.click(logoutButton)
  expect(keycloak.logout.mock.calls.length).toBe(1)
})
