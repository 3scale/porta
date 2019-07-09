import { isBrowserIE11 } from 'utilities/ie11Utils'

describe('isBrowserIE11', () => {
  it('should return false if user agent is not Trident/7.0', () => {
    expect(isBrowserIE11()).toEqual(false)
  })

  it('should return true if user agent is Trident/7.0', () => {
    Object.defineProperty(global.window.navigator, 'userAgent', {
      value: 'Trident/7.0'
    })
    expect(isBrowserIE11()).toEqual(true)
  })
})
