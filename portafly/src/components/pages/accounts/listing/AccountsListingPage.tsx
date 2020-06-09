import React from 'react'
import { useAsync } from 'react-async'
import { useDocumentTitle, Loading, DataListProvider } from 'components'
import { AccountsListingTable, generateColumns, generateRows } from 'components/pages/accounts/listing'
import {
  Alert,
  PageSection,
  TextContent,
  Text,
  Button,
  Flex,
  FlexItem,
  FlexModifiers
} from '@patternfly/react-core'
import { getDeveloperAccounts } from 'dal/accounts'
import { useTranslation } from 'i18n/useTranslation'
import { PlusCircleIcon, ExportIcon } from '@patternfly/react-icons'
import { IDeveloperAccount } from 'types'

const AccountsListingPage: React.FunctionComponent = () => {
  const { data: accounts, error, isPending } = useAsync(getDeveloperAccounts)
  const { t } = useTranslation('audienceAccountsListing')
  useDocumentTitle(t('title_page'))

  const isMultitenant = false // TODO: get this somehow

  const DataListTable = ({ accounts: _accounts }: { accounts: IDeveloperAccount[] }) => {
    const columns = generateColumns(t)
    const rows = generateRows(_accounts, isMultitenant)

    const initialState = {
      table: { columns, rows }
    }

    return (
      <DataListProvider initialState={initialState}>
        <AccountsListingTable />
      </DataListProvider>
    )
  }

  return (
    <>
      <PageSection variant="light">
        <Flex>
          <FlexItem>
            <TextContent>
              <Text component="h1">{t('title_page')}</Text>
            </TextContent>
          </FlexItem>
          <FlexItem breakpointMods={[{ modifier: FlexModifiers['align-right'] }]}>
            <Button
              variant="link"
              icon={<PlusCircleIcon />}
              aria-label={t('create_account_button_aria_label')}
            >
              {t('create_account_button')}
            </Button>
            <Button
              variant="link"
              icon={<ExportIcon />}
              aria-label={t('export_accounts_button_aria_label')}
            >
              {t('export_accounts_button')}
            </Button>
          </FlexItem>
        </Flex>
      </PageSection>

      <PageSection>
        {isPending && <Loading />}
        {error && <Alert variant="danger" title={error.message} />}
        {accounts && <DataListTable accounts={accounts} />}
      </PageSection>
    </>
  )
}

// Default export needed for React.lazy
// eslint-disable-next-line import/no-default-export
export default AccountsListingPage
