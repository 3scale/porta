import React, { createContext, useContext, useState } from 'react'
import { getToken, setToken } from 'utils'
import { AuthToken } from 'types/auth'

interface IAuthContext {
  authToken: AuthToken,
  setAuthToken: (t: AuthToken) => void
}

const AuthContext = createContext<IAuthContext>({
  authToken: null,
  setAuthToken: () => {}
})

const AuthProvider: React.FunctionComponent = ({ children }) => {
  const existingToken = getToken()
  const [authToken, setAuthToken] = useState(existingToken)

  const saveToken = (token: AuthToken) => {
    setToken(token)
    setAuthToken(token)
  }
  return (
    <AuthContext.Provider value={{ authToken, setAuthToken: saveToken }}>
      {children}
    </AuthContext.Provider>
  )
}

const useAuth = () => useContext(AuthContext)

export { AuthProvider, useAuth }
