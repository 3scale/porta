import React from 'react'
import { useDocumentTitle, Loading } from 'components'
import { DeveloperAccountsTable } from 'components/developer-accounts'
import {
  Alert,
  PageSection,
  PageSectionVariants,
  TextContent,
  Text,
  Button
} from '@patternfly/react-core'
import { useGetDeveloperAccounts } from 'dal/accounts'
import { useTranslation } from 'i18n/useTranslation'
import { PlusCircleIcon, ExportIcon } from '@patternfly/react-icons'

import './developerAccounts.scss'

const DeveloperAccounts: React.FunctionComponent = () => {
  const { t } = useTranslation('accounts')
  useDocumentTitle(t('page_title'))

  const { accounts, error, isPending } = useGetDeveloperAccounts()

  return (
    <>
      <PageSection id="developer-accounts-title-section" variant={PageSectionVariants.light}>
        <TextContent>
          <Text component="h1">{t('body_title')}</Text>
        </TextContent>
        <Button variant="link" icon={<ExportIcon />}>{t('header_buttons.export_accounts')}</Button>
        <Button variant="link" icon={<PlusCircleIcon />}>{t('header_buttons.create_account')}</Button>
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
