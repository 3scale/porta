global.fetch = jest.fn()

const jQueryMock = () => $

// rails flash
jQueryMock.flash = {
  notice: jest.fn(),
  error: jest.fn()
}

// rails ujs
jQueryMock.live = () => jQueryMock

global.$ = jQueryMock
