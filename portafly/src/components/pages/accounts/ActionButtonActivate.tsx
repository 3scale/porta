import React from 'react'
import { Button } from '@patternfly/react-core'
import { PlayCircleIcon } from '@patternfly/react-icons'
import { useTranslation } from 'i18n/useTranslation'

const ActionButtonActivate = () => {
  const { t } = useTranslation('accountsIndex')

  const onClick = () => {
    // TODO
  }

  return (
    <Button
      variant="link"
      icon={<PlayCircleIcon />}
      onClick={onClick}
    >
      {t('accounts_table.actions_column_options.activate')}
    </Button>
  )
}

export { ActionButtonActivate }
