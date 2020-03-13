import 'react-app-polyfill/ie11'

import React from 'react'
import { BrowserRouter as Router, Redirect } from 'react-router-dom'
import { SwitchWith404, LazyRoute, Root } from 'components'
import { LastLocationProvider } from 'react-router-last-location'

import { I18nProvider } from 'i18n'

const getOverviewPage = () => import('pages/Overview')
const getApplicationsPage = () => import('pages/Applications')

const PagesSwitch = () => (
  <SwitchWith404>
    <LazyRoute path="/" exact getComponent={getOverviewPage} />
    <LazyRoute path="/applications" exact getComponent={getApplicationsPage} />
    <Redirect path="/overview" to="/" exact />
  </SwitchWith404>
)

const App = () => (
  <Router>
    <LastLocationProvider>
      <I18nProvider>
        <Root>
          <PagesSwitch />
        </Root>
      </I18nProvider>
    </LastLocationProvider>
  </Router>
)

export { App }
