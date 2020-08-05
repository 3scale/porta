/* eslint-disable no-console */
import React from 'react'
import ReactDOM from 'react-dom'
import '@patternfly/react-core/dist/styles/base.css'
import 'i18n/i18n'
import { AuthProvider, keycloak } from 'auth'
import { App } from 'App'

keycloak.init({ onLoad: 'login-required' }).then((auth) => {
  if (!auth) window.location.reload()
  keycloak.loadUserProfile().then((userProfile) => (
    // eslint-disable-next-line react/no-render-return-value
    ReactDOM.render(<AuthProvider userProfile={userProfile} keycloak={keycloak}><App /></AuthProvider>, document.getElementById('root'))
  )).catch((e) => {
    throw new Error(`The application failed to retrieve user Profile: ${e}`)
  })
}).catch((e) => console.log('Authentication ERROR', e))
