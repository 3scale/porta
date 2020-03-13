import 'react-app-polyfill/ie11'
import { Brand } from '@patternfly/react-core'
import React from 'react'
import { useHistory } from 'react-router-dom'
import { AppLayout } from 'components'
import { useLocalization } from 'i18n'
import logo from 'assets/logo.svg'

const Logo = <Brand src={logo} alt="patternfly logo" />

const Root: React.FunctionComponent = ({ children }) => {
  const { t } = useLocalization()

  const navItems = [
    {
      title: t('nav_overview'),
      to: '/',
      exact: true
    },
    {
      title: t('nav_analytics'),
      to: '/analytics',
      items: [
        { to: '/analytics/usage', title: 'Usage' }
      ]
    },
    {
      title: t('nav_applications'),
      to: '/applications',
      items: [
        { to: '/applications', title: 'Listing' },
        { to: '/applications/plans', title: 'Application Plans' }
      ]
    },
    {
      title: t('nav_integration'),
      to: '/integration',
      items: [
        { to: '/integration/configuration', title: 'Configuration' }
      ]
    }
  ]

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
      navVariant="vertical"
      navItems={navItems}
      navGroupsStyle="expandable"
    >
      {children}
    </AppLayout>
  )
}

export { Root }
