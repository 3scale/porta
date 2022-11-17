import { useState } from 'react'
import { Card } from '@patternfly/react-core'

import { PlansTable } from 'Plans/components/PlansTable'
import * as flash from 'utilities/flash'
import { ajax } from 'utilities/ajax'
import { waitConfirm } from 'utilities/confirm-dialog'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent } from 'react'
import type { Action, Plan } from 'Types'

interface Props {
  columns: {
    attribute: string;
    title: string;
  }[];
  plans: Plan[];
  count: number;
  searchHref: string;
}

const PlansTableCard: FunctionComponent<Props> = ({
  columns,
  plans: initialPlans,
  count,
  searchHref
}) => {
  const [plans, setPlans] = useState<Plan[]>(initialPlans)
  const [isLoading, setIsLoading] = useState<boolean>(false)

  const handleActionCopy = (path: string) => ajax(path, { method: 'POST' })
    .then(data => data.json()
      .then((res: { notice: string; plan: string; error: string }) => {
        if (data.status === 201) {
          flash.notice(res.notice)
          const newPlan = JSON.parse(res.plan) as Plan
          setPlans([...plans, newPlan])
        } else if (data.status === 422) {
          flash.error(res.error)
        }
      })
    )
    .catch(err => {
      console.error(err)
      flash.error('An error ocurred. Please try again later.')
    })
    .finally(() => { setIsLoading(false) })

  const handleActionDelete = (path: string) => waitConfirm('Are you sure?')
    .then(confirmed => {
      if (confirmed) {
        return ajax(path, { method: 'DELETE' })
          .then(data => data.json()
            .then((res: { notice: string; id: number }) => {
              if (data.status === 200) {
                flash.notice(res.notice)
                const purgedPlans = plans.filter(p => p.id !== res.id)
                setPlans(purgedPlans)
              }
            }))
      }
    })
    .catch(err => {
      console.error(err)
      flash.error('An error ocurred. Please try again later.')
    })
    .finally(() => { setIsLoading(false) })

  const handleActionPublishHide = (path: string) => ajax(path, { method: 'POST' })
    .then(data => data.json()
      .then((res: { notice: string; plan: string; error: string }) => {
        if (data.status === 200) {
          flash.notice(res.notice)
          const newPlan = JSON.parse(res.plan) as Plan
          const i = plans.findIndex(p => p.id === newPlan.id)
          plans[i] = newPlan
          setPlans(plans)
        } else if (data.status === 406) {
          flash.error(res.error)
        }
      })
    )
    .catch(err => {
      console.error(err)
      flash.error('An error ocurred. Please try again later.')
    })
    .finally(() => { setIsLoading(false) })

  const handleAction = ({ title, path }: Action) => {
    if (isLoading) {
      // Block table or something when is loading, show user feedback
      return
    }

    setIsLoading(true)

    switch (title) {
      case 'Copy':
        void handleActionCopy(path)
        break
      case 'Delete':
        void handleActionDelete(path)
        break
      case 'Publish':
      case 'Hide':
        void handleActionPublishHide(path)
        break
      default:
        console.error(`Unknown action: ${title}`)
    }
  }

  return (
    <Card id="default_plan_card">
      <PlansTable
        columns={columns}
        count={count}
        plans={plans}
        searchHref={searchHref}
        onAction={handleAction}
      />
    </Card>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const PlansTableCardWrapper = (props: Props, containerId: string): void => { createReactWrapper(<PlansTableCard {...props} />, containerId) }

export { PlansTableCard, PlansTableCardWrapper, Props }
