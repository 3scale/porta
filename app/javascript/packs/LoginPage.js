import React from 'react'
import { render } from 'react-dom'
import '@patternfly/react-core/dist/styles/base.css'
import SimpleLoginPage from 'LoginPage/index'

document.addEventListener('DOMContentLoaded', () => {
  render(<SimpleLoginPage />, document.getElementById('login-page-wrapper'))
})
