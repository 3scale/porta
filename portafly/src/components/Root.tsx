import React from 'react'
import { Brand } from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'
import { useHistory } from 'react-router-dom'
import { useAuth } from 'auth'
import Login from 'pages/Login'
import { AppLayout } from 'components'
import logo from 'assets/logo.svg'

const Root: React.FunctionComponent = ({ children }) => {
  const { t } = useTranslation('shared')
  const { authToken } = useAuth()
  const Logo = <Brand src={logo} alt={t('logo_alt_text')} />

  const navItems = [
    {
      title: t('nav_items.overview'),
      to: '/',
      exact: true
    },
    {
      title: t('nav_items.analytics'),
      to: '/analytics',
      items: [
        { to: '/analytics/usage', title: t('nav_items.analytics_usage') }
      ]
    },
    {
      title: t('nav_items.applications'),
      to: '/applications',
      items: [
        { to: '/applications', title: t('nav_items.applications_listing') },
        { to: '/applications/plans', title: t('nav_items.applications_app_plans') }
      ]
    },
    {
      title: t('nav_items.accounts'),
      to: '/accounts',
      items: [
        { to: '/accounts', title: t('nav_items.accounts_listing') }
      ]
    },
    {
      title: t('nav_items.integration'),
      to: '/integration',
      items: [
        { to: '/integration/configuration', title: t('nav_items.integration_configuration') }
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
  return authToken
    ? (
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
    : <Login />
}

export { Root }
