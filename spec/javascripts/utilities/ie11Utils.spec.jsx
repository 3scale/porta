import { isBrowserIE11 } from 'utilities/ie11Utils'

describe('isBrowserIE11', () => {
  const windowNotIE = {
    navigator: {
      userAgent: 'Chrome'
    }
  }
  it('should return false if user agent is not Trident/7.0', () => {
    expect(isBrowserIE11(windowNotIE)).toEqual(false)
  })

  it('should return true if user agent is Trident/7.0', () => {
    const windowIE = {
      navigator: {
        userAgent: 'Trident/7.0'
      }
    }
    expect(isBrowserIE11(windowIE)).toEqual(true)
  })
})
