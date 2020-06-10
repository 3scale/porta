import React from 'react'
import { Button } from '@patternfly/react-core'
import { CheckIcon } from '@patternfly/react-icons'
import { useTranslation } from 'i18n/useTranslation'

const ActionButtonApprove = () => {
  const { t } = useTranslation('accountsIndex')

  const onClick = () => {
    // TODO
  }

  return (
    <Button
      variant="link"
      icon={<CheckIcon />}
      onClick={onClick}
    >
      {t('accounts_table.actions_column_options.approve')}
    </Button>
  )
}

export { ActionButtonApprove }
