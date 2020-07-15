import React from 'react'
import { Button } from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'

const CreateAccountButton = () => {
  const { t } = useTranslation('accountsIndex')

  return (
    <Button
      aria-label={t('create_account_button_aria_label')}
      component="a"
      variant="primary"
      href="/accounts/new"
    >
      {t('create_account_button')}
    </Button>
  )
}

export { CreateAccountButton }
