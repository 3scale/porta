import { craftRequest } from 'utils/http'
import { getToken } from 'utils/auth'

jest.mock('utils/auth')

describe('craftRequest', () => {
  (getToken as jest.Mock).mockReturnValue('token')

  it('should throw when API_HOST is invalid', () => {
    process.env.REACT_APP_API_HOST = 'localhost'
    expect(() => craftRequest('planets')).toThrow()

    process.env.REACT_APP_API_HOST = '/wrong'
    expect(() => craftRequest('planets')).toThrow()
  })

  it('should craft the correct url provided API_HOST is valid', () => {
    const targetURL = 'http://starwars.db/planets?access_token=token'

    process.env.REACT_APP_API_HOST = 'http://starwars.db'
    expect(craftRequest('planets').url).toEqual(targetURL)

    process.env.REACT_APP_API_HOST = 'http://starwars.db/'
    expect(craftRequest('planets').url).toEqual(targetURL)

    process.env.REACT_APP_API_HOST = 'http://starwars.db'
    expect(craftRequest('/planets').url).toEqual(targetURL)

    process.env.REACT_APP_API_HOST = 'http://starwars.db/'
    expect(craftRequest('/planets').url).toEqual(targetURL)
  })

  it('should craft a valid url when API_HOST is unset', () => {
    delete process.env.REACT_APP_API_HOST
    expect(craftRequest('/planets').url).toEqual('/planets?access_token=token')
  })
})
