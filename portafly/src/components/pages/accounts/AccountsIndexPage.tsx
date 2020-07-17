import React from 'react'
import { useAsync } from 'react-async'
import {
  useDocumentTitle,
  Loading,
  AccountsDataListTable,
  CreateAccountButton,
  ExportAccountsButton
} from 'components'
import {
  Alert,
  PageSection,
  TextContent,
  Text,
  Flex,
  FlexItem
} from '@patternfly/react-core'
import { getDeveloperAccounts } from 'dal/accounts'
import { useTranslation } from 'i18n/useTranslation'

const AccountsIndexPage: React.FunctionComponent = () => {
  const { data: accounts, error, isPending } = useAsync(getDeveloperAccounts)
  const { t } = useTranslation('accountsIndex')
  useDocumentTitle(t('title_page'))

  return (
    <>
      <PageSection variant="light">
        <Flex>
          <FlexItem>
            <TextContent>
              <Text component="h1">{t('title_page')}</Text>
            </TextContent>
          </FlexItem>
          <FlexItem align={{ default: 'alignRight' }}>
            <CreateAccountButton />
          </FlexItem>
          <FlexItem>
            <ExportAccountsButton data={accounts} />
          </FlexItem>
        </Flex>
      </PageSection>

      <PageSection>
        {isPending && <Loading />}
        {error && <Alert variant="danger" title={error.message} />}
        {accounts && <AccountsDataListTable accounts={accounts} />}
      </PageSection>
    </>
  )
}

// Default export needed for React.lazy
// eslint-disable-next-line import/no-default-export
export default AccountsIndexPage
