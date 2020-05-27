import React from 'react'
import { useAsync } from 'react-async'
import { useDocumentTitle, Loading, DeveloperAccountsTable } from 'components'
import {
  Alert,
  PageSection,
  PageSectionVariants,
  TextContent,
  Text
} from '@patternfly/react-core'
import { getDeveloperAccounts } from 'dal/accounts'
import { useTranslation } from 'i18n/useTranslation'

const DeveloperAccounts: React.FunctionComponent = () => {
  const { data: accounts, error, isPending } = useAsync(getDeveloperAccounts)
  const { t } = useTranslation('accounts')
  useDocumentTitle(t('users.page_title'))

  return (
    <>
      <PageSection variant={PageSectionVariants.light}>
        <TextContent>
          <Text component="h1">{t('users.body_title')}</Text>
        </TextContent>
      </PageSection>

      <PageSection>
        {isPending && <Loading />}
        {error && <Alert variant="danger" title={error.message} />}
        {accounts && <DeveloperAccountsTable accounts={accounts} />}
      </PageSection>
    </>
  )
}

// Default export needed for React.lazy
// eslint-disable-next-line import/no-default-export
export default DeveloperAccounts
