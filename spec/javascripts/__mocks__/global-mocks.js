global.fetch = jest.fn()

const jQueryMock = () => $

// rails ujs
jQueryMock.live = () => jQueryMock

jQueryMock.on = () => jQueryMock

global.$ = jQueryMock
