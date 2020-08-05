import React, { createContext, useContext } from 'react'
import { AuthToken } from 'types/auth'
import { KeycloakInstance, KeycloakProfile } from 'keycloak-js'

interface IAuthContext {
  authToken: AuthToken,
  userProfile: KeycloakProfile,
  logout: () => any
}

const AuthContext = createContext<IAuthContext>({
  authToken: null,
  userProfile: {},
  logout: () => {}
})

type Props = {
  keycloak: KeycloakInstance,
  userProfile: KeycloakProfile
}

const AuthProvider: React.FunctionComponent<Props> = ({ keycloak, userProfile, children }) => (
  <AuthContext.Provider value={{
    authToken: keycloak.token as AuthToken,
    logout: keycloak.logout,
    userProfile
  }}
  >
    {children}
  </AuthContext.Provider>
)

const useAuth = () => useContext(AuthContext)

export { AuthProvider, useAuth }
