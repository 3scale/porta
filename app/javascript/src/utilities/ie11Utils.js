const isBrowserIE11 = (win = window) => !!win.navigator.userAgent.match(/Trident\/7\./)

export { isBrowserIE11 }
