// @flow

const post = (url: string, body?: URLSearchParams) => {
  const meta = document.querySelector('meta[name="csrf-token"]')
  const token = (meta && meta.getAttribute('content')) || ''

  return fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'X-CSRF-Token': token
    },
    body
  })
}

export { post }
