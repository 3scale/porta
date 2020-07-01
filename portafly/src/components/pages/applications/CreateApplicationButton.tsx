import React from 'react'
import { Button } from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'

const CreateApplicationButton = () => {
  const { t } = useTranslation('applicationsIndex')

  return (
    <Button
      aria-label={t('create_application_button_aria_label')}
      component="a"
      variant="primary"
      href="/applications/new"
    >
      {t('create_application_button')}
    </Button>
  )
}
export { CreateApplicationButton }
