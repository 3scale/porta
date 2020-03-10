import 'react-app-polyfill/ie11'
import { Brand } from '@patternfly/react-core'
import React from 'react'
import { BrowserRouter as Router, Redirect, useHistory } from 'react-router-dom'
import { AppLayout, SwitchWith404, LazyRoute } from 'components'
import { LastLocationProvider } from 'react-router-last-location'
import logo from 'assets/logo.svg'

const Logo = <Brand src={logo} alt={'patternfly logo'} />
const navItems = [
  {
    title: 'Overview',
    to: '/',
    exact: true
  },
  {
    title: 'Analytics',
    to: '/analytics',
    items: [
      { to: '/analytics/usage', title: 'Usage' }
    ]
  },
  {
    title: 'Applications',
    to: '/applications',
    items: [
      { to: '/applications', title: 'Listing' },
      { to: '/applications/plans', title: 'Application Plans' }
    ]
  },
  {
    title: 'Integration',
    to: '/integration',
    items: [
      { to: '/integration/configuration', title: 'Configuration' }
    ]
  }
]

const getOverviewPage = () => import('./pages/Overview')
const getApplicationsPage = () => import('./pages/Applications')

const App = () => {
  return (
    <Router>
      <LastLocationProvider>
        <Root />
      </LastLocationProvider>
    </Router>
  )
}

const PagesSwitch = () => {
  return (
    <SwitchWith404>
      <LazyRoute path='/' exact getComponent={getOverviewPage} />
      <LazyRoute path='/applications' exact getComponent={getApplicationsPage} />
      <Redirect
        path='/overview'
        to='/'
        exact
      />
    </SwitchWith404>
  )
}

const Root = () => {
  const history = useHistory()
  const logoProps = React.useMemo(
    () => ({
      onClick: () => history.push('/')
    }),
    [history]
  )
  return (
    <AppLayout
      logo={Logo}
      logoProps={logoProps}
      navVariant='vertical'
      navItems={navItems}
      navGroupsStyle='expandable'
    >
      <PagesSwitch />
    </AppLayout>
  )
}

export { App }
