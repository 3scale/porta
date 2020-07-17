import React from 'react'
import { useTranslation } from 'i18n/useTranslation'
import { CSVLink } from 'react-csv'
import { IDeveloperAccount } from 'types'

interface Props {
  data?: IDeveloperAccount[]
}
const ExportAccountsButton: React.FunctionComponent<Props> = ({ data }) => {
  const { t } = useTranslation('accountsIndex')

  const exportHeaders = [
    { label: 'ID', key: 'id' },
    { label: t('accounts_table.admin_header'), key: 'adminName' },
    { label: t('accounts_table.group_header'), key: 'orgName' },
    { label: t('accounts_table.state_header'), key: 'state' },
    { label: t('accounts_table.applications_header'), key: 'appsCount' },
    { label: t('accounts_table.created_header'), key: 'createdAt' },
    { label: t('accounts_table.updated_header'), key: 'updatedAt' }
  ]

  const isDisabled = !(data && data.length)

  return (
    <CSVLink
      filename="accounts.csv"
      headers={exportHeaders}
      data={data || []}
      className={`pf-c-button pf-m-secondary ${isDisabled ? 'pf-m-disabled' : ''}`}
      aria-label={t('export_accounts_button_aria_label')}
      onClick={() => !isDisabled}
    >
      {t('export_accounts_button')}
    </CSVLink>
  )
}

export { ExportAccountsButton }
