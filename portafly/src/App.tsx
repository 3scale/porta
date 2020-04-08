import 'react-app-polyfill/ie11'
import React from 'react'
import { BrowserRouter as Router, Redirect } from 'react-router-dom'
import { SwitchWith404, LazyRoute, Root } from 'components'
import { LastLocationProvider } from 'react-router-last-location'

const getOverviewPage = () => import('pages/Overview')
const getApplicationsPage = () => import('pages/Applications')
const getAccountsPage = () => import('pages/DeveloperAccounts')

const PagesSwitch = () => (
  <SwitchWith404>
    <LazyRoute path="/" exact getComponent={getOverviewPage} />
    <LazyRoute path="/applications" exact getComponent={getApplicationsPage} />
    <LazyRoute path="/accounts" exact getComponent={getAccountsPage} />
    <Redirect path="/overview" to="/" exact />
  </SwitchWith404>
)

const App = () => (
  <Router>
    <LastLocationProvider>
      <Root>
        <PagesSwitch />
      </Root>
    </LastLocationProvider>
  </Router>
)

export { App }
