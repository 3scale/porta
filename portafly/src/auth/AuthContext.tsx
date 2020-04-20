import React, { createContext, useContext, useState } from 'react'

type AuthToken = string | null

interface IAuthContext {
  authToken: AuthToken,
  setAuthToken: (t: AuthToken) => void
}

const AuthContext = createContext<IAuthContext>({
  authToken: null,
  setAuthToken: () => {}
})

const AuthProvider: React.FunctionComponent = ({ children }) => {
  const existingToken = localStorage.getItem('token')
  const [authToken, setAuthToken] = useState(existingToken && JSON.parse(existingToken))

  const setToken = (token: AuthToken) => {
    localStorage.setItem('token', JSON.stringify(token))
    setAuthToken(token)
  }
  return (
    <AuthContext.Provider value={{ authToken, setAuthToken: setToken }}>
      {children}
    </AuthContext.Provider>
  )
}

const useAuth = () => useContext(AuthContext)

export { AuthProvider, useAuth }
