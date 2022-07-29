// @flow

import * as React from 'react'

import { Card } from '@patternfly/react-core'
import { PlansTable } from 'Plans/components/PlansTable'
import * as alert from 'utilities/alert'
import {
  ajax,
  createReactWrapper,
  safeFromJsonString,
  confirm
} from 'utilities'

import type { Plan, Action } from 'Types'

export type Props = {
  columns: Array<{ attribute: string, title: string }>,
  plans: Plan[],
  count: number,
  searchHref: string,
}

const PlansTableCard = ({ columns, plans: initialPlans, count, searchHref }: Props): React.Node => {
  const [plans, setPlans] = React.useState<Plan[]>(initialPlans)
  const [isLoading, setIsLoading] = React.useState<boolean>(false)

  const handleActionCopy = (path) => ajax(path, { method: 'POST' })
    .then(data => data.json()
      .then(res => {
        if (data.status === 201) {
          alert.notice(res.notice)
          // $FlowIgnore[incompatible-type] we can assume safely this is a plan
          const newPlan: Plan = safeFromJsonString(res.plan)
          setPlans([...plans, newPlan])
        } else if (data.status === 422) {
          alert.error(res.error)
        }
      })
    )
    .catch(err => {
      console.error(err)
      alert.error('An error ocurred. Please try again later.')
    })
    .finally(() => setIsLoading(false))

  const handleActionDelete = (path) => confirm('Are you sure?')
    .then(confirmed => {
      if (confirmed) {
        return ajax(path, { method: 'DELETE' })
          .then(data => data.json().then(res => {
            if (data.status === 200) {
              window.$.flash.notice(res.notice)
              const purgedPlans = plans.filter(p => p.id !== res.id)
              setPlans(purgedPlans)
            }
          }))
      }
    })
    .catch(err => {
      console.error(err)
      alert.error('An error ocurred. Please try again later.')
    })
    .finally(() => setIsLoading(false))

  const handleActionPublishHide = (path) => ajax(path, { method: 'POST' })
    .then(data => data.json()
      .then(res => {
        if (data.status === 200) {
          alert.notice(res.notice)
          // $FlowIgnore[incompatible-type] we can assume safely this is a plan
          const newPlan: Plan = safeFromJsonString(res.plan)
          const i = plans.findIndex(p => p.id === newPlan.id)
          plans[i] = newPlan
          setPlans(plans)
        }

        if (data.status === 406) {
          alert.error(res.error)
        }
      })
    )
    .catch(err => {
      console.error(err)
      alert.error('An error ocurred. Please try again later.')
    })
    .finally(() => setIsLoading(false))

  const handleAction = ({ title, path, method }: Action) => {
    if (isLoading) {
      // Block table or something when is loading, show user feedback
      return
    }

    setIsLoading(true)

    switch (title) {
      case 'Copy':
        handleActionCopy(path)
        break
      case 'Delete':
        handleActionDelete(path)
        break
      case 'Publish':
      case 'Hide':
        handleActionPublishHide(path)
        break
      default:
        console.error(`Unknown action: ${title}`)
    }
  }

  return (
    <Card id="default_plan_card">
      <PlansTable
        columns={columns}
        plans={plans}
        count={count}
        searchHref={searchHref}
        onAction={handleAction}
      />
    </Card>
  )
}

const PlansTableCardWrapper = (props: Props, containerId: string): void => (
  createReactWrapper(<PlansTableCard {...props} />, containerId)
)

export { PlansTableCard, PlansTableCardWrapper }
