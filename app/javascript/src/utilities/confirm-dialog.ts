export function waitConfirm (message: string): Promise<boolean> {
  return Promise.resolve(window.confirm(message))
}
