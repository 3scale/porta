/**
 * TODO: Send an email to a list of admins
 */
function sendEmail() {
  return new Promise((res, rej) => {
    setTimeout(() => (Date.now() % 2 ? res() : rej()), 1000)
  })
}

/**
 * TODO: Change the state of a list of accounts
 */
function changeState() {
  return new Promise((res, rej) => {
    setTimeout(() => (Date.now() % 2 ? res() : rej()), 1000)
  })
}

export { sendEmail, changeState }
