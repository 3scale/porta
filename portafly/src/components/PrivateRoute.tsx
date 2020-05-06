import React from 'react'
import { Redirect } from 'react-router-dom'
import { useAuth } from 'auth'

const PrivateRoute: React.FunctionComponent = ({ children }) => {
  const { authToken } = useAuth()

  return authToken ? <>{ children }</> : <Redirect to="/login" />
}

export { PrivateRoute }
