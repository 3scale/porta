// @flow

import * as React from 'react'

import { Card } from '@patternfly/react-core'
import { ApplicationPlansTable } from 'Plans'
import * as alert from 'utilities/alert'
import {
  ajax,
  safeFromJsonString,
  confirm
} from 'utilities'

import type { ApplicationPlan, Action } from 'Types'

export type Props = {
  plans: ApplicationPlan[],
  count: number,
  searchHref: string,
}

const ApplicationPlansTableCard = ({ plans: initialPlans, count, searchHref }: Props): React.Node => {
  const [plans, setPlans] = React.useState<ApplicationPlan[]>(initialPlans)
  const [isLoading, setIsLoading] = React.useState<boolean>(false)

  const handleActionCopy = (path) => ajax(path, { method: 'POST' })
    .then(data => data.json()
      .then(res => {
        if (data.status === 201) {
          alert.notice(res.notice)
          // $FlowIgnore[incompatible-type] we can assume safely this is a plan
          const newPlan: ApplicationPlan = safeFromJsonString(res.plan)
          setPlans([...plans, newPlan])
        } else {
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
              alert.notice(res.notice)
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
          const newPlan: ApplicationPlan = safeFromJsonString(res.plan)
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
