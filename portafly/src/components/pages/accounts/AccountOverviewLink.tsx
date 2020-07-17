import React from 'react'
import { IAccount } from 'types'
import { useTranslation } from 'i18n/useTranslation'
import { Button } from '@patternfly/react-core'

interface Props {
  account: IAccount
}

const AccountOverviewLink: React.FunctionComponent<Props> = ({ account }) => {
  const { t } = useTranslation('accountsIndex')

  return (
    <Button
      aria-label={t('accounts_table.account_overview_link_aria_label')}
      component="a"
      variant="link"
      href={`/accounts/${account.id}`}
      isInline
    >
      {account.orgName}
    </Button>
  )
}

export { AccountOverviewLink }
