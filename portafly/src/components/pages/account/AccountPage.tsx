import React, { useState } from 'react'
import { useDocumentTitle, CreateApplicationButton } from 'components'
import { OverviewTabContent, ApplicationsTabContent } from 'components/pages/account'
import { useTranslation } from 'i18n/useTranslation'
import {
  PageSection,
  Text,
  TextContent,
  Tabs,
  Tab,
  TabTitleText,
  Flex,
  FlexItem
} from '@patternfly/react-core'
import { useHistory } from 'react-router'
import { useAsync } from 'react-async'
import { getAccount } from 'dal/account'

import './accountPage.scss'

type OnSelect = (event: React.MouseEvent, eventKey: React.ReactText) => void

type TabKey = 'overview' | 'applications'

interface Props {
  accountId: string
}

const AccountOverviewPage: React.FunctionComponent<Props> = ({
  accountId
}) => {
  const { t } = useTranslation('accountOverview')
  useDocumentTitle(t('overview.page_title'))

  const { data: account, error, isPending } = useAsync(getAccount, { accountId })

  const tabs = [
    {
      key: 'overview',
      href: `/accounts/${accountId}/overview`,
      title: t('overview.overview_title'),
      render: () => <OverviewTabContent account={account} error={error} isPending={isPending} />
    },
    {
      key: 'applications',
      href: `/accounts/${accountId}/applications`,
      title: t('overview.applications_title'),
      render: () => <ApplicationsTabContent accountId={accountId} />
    }
  ]

  const history = useHistory()
  const initialTab = tabs.find((tab) => tab.href === history.location.pathname)
  const [activeTab, setActiveTab] = useState(initialTab?.key || 'overview')

  const handleTabClick: OnSelect = (_event, tabKey) => {
    const match = tabs.find((tab) => tab.key === tabKey)

    if (match) {
      setActiveTab(tabKey as TabKey)
      history.push(match.href)
    }
  }

  return (
    <div className="account-page">
      <PageSection variant="light">
        <Flex>
          <FlexItem>
            <TextContent>
              <Text component="h1">{account?.orgName}</Text>
            </TextContent>
          </FlexItem>
          <FlexItem align={{ default: 'alignRight' }}>
            { activeTab === 'applications' && <CreateApplicationButton /> }
          </FlexItem>
        </Flex>
      </PageSection>

      <Tabs
        mountOnEnter
        activeKey={activeTab}
        onSelect={handleTabClick}
      >
        {tabs.map(({ title, key, render }) => (
          <Tab
            aria-label={title}
            eventKey={key}
            key={key}
            title={<TabTitleText>{title}</TabTitleText>}
          >
            {render()}
          </Tab>
        ))}
      </Tabs>
    </div>
  )
}

// Default export needed for React.lazy
// eslint-disable-next-line import/no-default-export
export default AccountOverviewPage
