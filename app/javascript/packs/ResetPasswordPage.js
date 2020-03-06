import '@babel/polyfill'
import 'core-js/es7/object'
import React from 'react'
import { render } from 'react-dom'
import {isBrowserIE11} from 'utilities/ie11Utils'
import {safeFromJsonString} from 'utilities/json-utils'

import {
  LoginPage
} from '@patternfly/react-core'

import {
  RequestPasswordForm,
  FlashMessages
} from 'LoginPage'

import 'LoginPage/assets/styles/loginPage.scss'
import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'

const isIE11 = isBrowserIE11(window)
if (isIE11) {
  // eslint-disable-next-line no-unused-expressions
  import('LoginPage/assets/styles/ie11-pf4BaseStyles.css')
}

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('pf-reset-page-container')
  if (isIE11) {
    container.classList.add('isIe11', 'pf-c-page')
  }
  const resetPageProps = safeFromJsonString(container.dataset.resetProps)

  render(
    <LoginPage
      brandImgSrc={brandImg}
      brandImgAlt='Red Hat 3scale API Management'
      backgroundImgSrc={PF4DownstreamBG}
      backgroundImgAlt='Red Hat 3scale API Management'
      loginTitle='Request a password reset link by email'
      footer={null}
    >
      {
        resetPageProps.flashMessages &&
        <FlashMessages flashMessages={resetPageProps.flashMessages}/>
      }
      <RequestPasswordForm
        providerPasswordPath={resetPageProps.providerPasswordPath}
        providerLoginPath={resetPageProps.providerLoginPath}
      />
    </LoginPage>, container)
})
