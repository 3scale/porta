import React from 'react'
import { useDocumentTitle, Loading, DeveloperAccountsTable } from 'components'
import {
  Alert,
  PageSection,
  PageSectionVariants,
  TextContent,
  Text
} from '@patternfly/react-core'
import { useGetDeveloperAccounts } from 'dal/accounts'
import { useTranslation } from 'i18n/useTranslation'

const DeveloperAccounts: React.FunctionComponent = () => {
  const { t } = useTranslation('accounts')
  useDocumentTitle(t('page_title'))

  const { accounts, error, isPending } = useGetDeveloperAccounts()

  return (
    <>
      <PageSection variant={PageSectionVariants.light}>
        <TextContent>
          <Text component="h1">{t('body_title')}</Text>
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
