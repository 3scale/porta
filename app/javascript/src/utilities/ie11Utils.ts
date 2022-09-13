export function isBrowserIE11 (win = window) {
  return !!win.navigator.userAgent.match(/Trident\/7\./)
}
