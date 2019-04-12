import React from 'react'
import { render } from 'react-dom'
import SimpleLoginPage from 'SimpleLoginPage/index'

document.addEventListener('DOMContentLoaded', () => {
  render(<SimpleLoginPage />, document.getElementById('login-page-wrapper'))
})
