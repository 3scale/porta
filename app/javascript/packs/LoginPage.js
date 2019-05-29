import React from 'react'
import { render } from 'react-dom'
import '@patternfly/react-core/dist/styles/base.css'
import {LoginPageWrapper} from 'LoginPage'
import {safeFromJsonString} from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const loginPageContainer = document.getElementById('login-page-wrapper')
  const loginPageProps = safeFromJsonString(loginPageContainer.dataset.loginProps)
  LoginPageWrapper(LoginPageWrapper, 'login-page-wrapper')
})
