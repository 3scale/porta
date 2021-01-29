// @flow

const post = (url: string, body?: URLSearchParams) => fetch(url, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
  },
  body
})

export { post }
