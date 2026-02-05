function navigate (href: string): void {
  window.location.assign(href)
}

function replace (href: string): void {
  window.location.replace(href)
}

export { navigate, replace }
