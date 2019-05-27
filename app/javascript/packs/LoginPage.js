import React from 'react'
import { render } from 'react-dom'
import SimpleLoginPage from 'LoginPage/index'
import '@patternfly/react-core/dist/styles/base.css'

document.addEventListener('DOMContentLoaded', () => {
  render(<SimpleLoginPage />, document.getElementById('login-page-wrapper'))
})
