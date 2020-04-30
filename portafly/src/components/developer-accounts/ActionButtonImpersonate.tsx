import React from 'react'
import { useTranslation } from 'react-i18next'
import { Button } from '@patternfly/react-core'
import { BoltIcon } from '@patternfly/react-icons'

const ActionButtonImpersonate = () => {
  const { t } = useTranslation('accounts')

  const onClick = () => {
    console.log('Impersonating...')
  }

  return (
    <Button
      variant="link"
      icon={<BoltIcon />}
      onClick={onClick}
    >
      {t('accounts_table.actions.impersonate')}
    </Button>
  )
}

export { ActionButtonImpersonate }
