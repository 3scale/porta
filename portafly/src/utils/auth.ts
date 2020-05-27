import { AuthToken } from 'types/auth'

const getToken = () => JSON.parse(String(localStorage.getItem('token'))) as AuthToken
const setToken = (token: AuthToken) => (
  token
    ? localStorage.setItem('token', JSON.stringify(token))
    : localStorage.removeItem('token')
)

export { getToken, setToken }
