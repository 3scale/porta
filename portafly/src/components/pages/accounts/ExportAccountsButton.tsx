import React from 'react'
import { useTranslation } from 'i18n/useTranslation'
import { ExportIcon } from '@patternfly/react-icons'
import { CSVLink } from 'react-csv'
import { IDeveloperAccount } from 'types'

const ExportAccountsButton = ({ data }: {data: IDeveloperAccount[]}) => {
  const { t } = useTranslation('accountsIndex')

  const exportHeaders = [
    { label: 'ID', key: 'id' },
    { label: t('accounts_table.admin_header'), key: 'admin_name' },
    { label: t('accounts_table.group_header'), key: 'org_name' },
    { label: t('accounts_table.state_header'), key: 'state' },
    { label: t('accounts_table.applications_header'), key: 'apps_count' },
    { label: t('accounts_table.created_header'), key: 'created_at' },
    { label: t('accounts_table.updated_header'), key: 'update_at' }
  ]

  return (
    <CSVLink
      filename="accounts.csv"
      headers={exportHeaders}
      data={data}
      className="pf-c-button pf-m-link"
      aria-label={t('export_accounts_button_aria_label')}
    >
      <span className="pf-c-button__icon pf-m-start"><ExportIcon /></span>
      {t('export_accounts_button')}
    </CSVLink>
  )
}

export { ExportAccountsButton }
