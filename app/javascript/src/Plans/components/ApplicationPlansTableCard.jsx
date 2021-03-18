// @flow

import * as React from 'react'

import { Card } from '@patternfly/react-core'
// $FlowIgnore[missing-export] export is there, name_mapper is the problem
import { ApplicationPlansTable } from 'Plans'
import * as alert from 'utilities/alert'
import { ajax } from 'utilities/ajax'
import { safeFromJsonString } from 'utilities/json-utils'

import type { ApplicationPlan, Action } from 'Types'

export type Props = {
  plans: ApplicationPlan[],
  count: number,
  searchHref: string,
}

const ApplicationPlansTableCard = ({ plans: initialPlans, count, searchHref }: Props): React.Node => {
  const [plans, setPlans] = React.useState(initialPlans)
  const [isLoading, setIsLoading] = React.useState<boolean>(false)

  const handleAction = ({ path, method }: Action) => {
    if (isLoading) {
      return
    }

    ajax(path, method)
      .then(data => data.json())
      .then(res => {
        res.notice ? alert.notice(res.notice) : alert.error(res.error)
        const { plan } = res
        if (plan) {
          setPlans([...plans, safeFromJsonString<ApplicationPlan>(plan)])
        }
      })
      .catch(err => {
        console.error(err)
        alert.error('An error ocurred. Please try again later.')
      })
      .finally(() => setIsLoading(false))

    setIsLoading(true)
  }

  return (
    <Card id="default_plan_card">
      <ApplicationPlansTable
        plans={plans}
        count={count}
        searchHref={searchHref}
        onAction={handleAction}
      />
    </Card>
  )
}

export { ApplicationPlansTableCard }
