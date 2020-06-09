import React from 'react'
import { useTranslation } from 'react-i18next'
import { Button } from '@patternfly/react-core'
import { BoltIcon } from '@patternfly/react-icons'

const ActionButtonImpersonate = () => {
  const { t } = useTranslation('accountsIndex')

  const onClick = () => {
    // TODO
  }

  return (
    <Button
      variant="link"
      icon={<BoltIcon />}
      onClick={onClick}
    >
      {t('actions_column_options.act_as')}
    </Button>
  )
}

export { ActionButtonImpersonate }
