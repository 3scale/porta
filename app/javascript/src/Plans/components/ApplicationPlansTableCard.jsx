// @flow

import * as React from 'react'
// import { post } from 'utilities/ajax'
import {
  Card
} from '@patternfly/react-core'
// $FlowIgnore[missing-export] export is there, name_mapper is the problem
import { ApplicationPlansTable } from 'Plans'
// import { Spinner } from 'Common'
// import * as alert from 'utilities/alert'
import type { ApplicationPlan } from 'Types'
// import './DefaultPlanSelectCard.scss'

export type Props = {
  plans: ApplicationPlan[],
  count: number,
  searchHref: string,
}

const ApplicationPlansTableCard = ({ plans, count, searchHref }: Props): React.Node => {
  // const [isLoading, setIsLoading] = React.useState(false)

  // const onAction = () => {
  // const body = plan.id >= 0 ? new URLSearchParams({ id: plan.id.toString() }) : undefined
  // const url = path.replace(':id', String(product.id))

  // post(url, body)
  //   .then(data => {
  //     if (data.ok) {
  //       alert.notice('Default plan was updated')
  //       setDefaultPlan(plan)
  //     } else {
  //       if (data.status === 404) {
  //         alert.error("The selected plan doesn't exist.")
  //       } else {
  //         alert.error('Plan could not be updated')
  //       }
  //     }
  //   })
  //   .catch(err => {
  //     console.error(err)
  //     alert.error('An error ocurred. Please try again later.')
  //   })
  //   .finally(() => setIsLoading(false))

  //   setIsLoading(true)
  // }

  return (
    <Card id="default_plan_card">
      <ApplicationPlansTable
        plans={plans}
        count={count}
        searchHref={searchHref}
      />
    </Card>
  )
}

export { ApplicationPlansTableCard }
