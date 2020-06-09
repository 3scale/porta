import React from 'react'
import { useAsync } from 'react-async'
import { useDocumentTitle, Loading, AccountsDataListTable } from 'components'
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
        {accounts && <AccountsDataListTable accounts={accounts} />}
      </PageSection>
    </>
  )
}

// Default export needed for React.lazy
// eslint-disable-next-line import/no-default-export
export default AccountsIndexPage
