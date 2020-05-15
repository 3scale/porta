// Token is stored in JSON and not string since in the future we will be working with JWT
export type AuthToken = Object | null
const getToken = () => JSON.parse(String(localStorage.getItem('token'))) as AuthToken
const setToken = (token: AuthToken) => (
  token
    ? localStorage.setItem('token', JSON.stringify(token))
    : localStorage.removeItem('token')
)

export { getToken, setToken }
