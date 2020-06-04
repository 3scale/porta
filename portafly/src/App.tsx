import 'react-app-polyfill/ie11'
import React from 'react'
import { BrowserRouter as Router, Redirect } from 'react-router-dom'
import { AuthProvider } from 'auth'
import {
  SwitchWith404,
  LazyRoute,
  Root,
  AlertsProvider
} from 'components'
import { LastLocationProvider } from 'react-router-last-location'

const getOverviewPage = () => import('components/pages/Overview')
const getApplicationsPage = () => import('components/pages/Applications')
const getAccountsPage = () => import('components/pages/audience/accounts/listing/DeveloperAccounts')

const PagesSwitch = () => (
  <SwitchWith404>
    <LazyRoute path="/" exact getComponent={getOverviewPage} />
    <LazyRoute path="/applications" exact getComponent={getApplicationsPage} />
    <LazyRoute path="/accounts" exact getComponent={getAccountsPage} />
    <Redirect path="/overview" to="/" exact />
  </SwitchWith404>
)

const App = () => (
  <AuthProvider>
    <Router>
      <LastLocationProvider>
        <AlertsProvider>
          <Root>
            <PagesSwitch />
          </Root>
        </AlertsProvider>
      </LastLocationProvider>
    </Router>
  </AuthProvider>
)

export { App }
