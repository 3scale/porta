global.fetch = () => {}

const jQueryMock = () => $

// rails flash
jQueryMock.flash = {
  notice: () => {},
  error: () => {}
}

// rails ujs
jQueryMock.live = () => jQueryMock

global.$ = jQueryMock
