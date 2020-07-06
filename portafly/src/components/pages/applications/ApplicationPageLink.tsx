import React from 'react'
import { IApplication } from 'types'
import { useTranslation } from 'i18n/useTranslation'
import { Button } from '@patternfly/react-core'

interface Props {
  application: IApplication
}

const ApplicationPageLink: React.FunctionComponent<Props> = ({ application }) => {
  const { t } = useTranslation('applicationsIndex')

  return (
    <Button
      aria-label={t('applications_table.application_overview_link_aria_label')}
      component="a"
      variant="link"
      href={`/applications/${application.id}`}
      isInline
    >
      {application.name}
    </Button>
  )
}

export { ApplicationPageLink }
