import React from 'react'
import { IPlan } from 'types'
import { useTranslation } from 'i18n/useTranslation'
import { Button } from '@patternfly/react-core'

interface Props {
  plan: IPlan
}

const PlanOverviewLink: React.FunctionComponent<Props> = ({ plan }) => {
  const { t } = useTranslation('applicationsPlans')

  return (
    <Button
      aria-label={t('plan_overview_link_aria_label')}
      component="a"
      variant="link"
      href={`/plans/${plan.id}`}
      isInline
    >
      {plan.name}
    </Button>
  )
}

export { PlanOverviewLink }
