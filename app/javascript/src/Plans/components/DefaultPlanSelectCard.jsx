// @flow

import * as React from 'react'

import { Form, Card, CardBody } from '@patternfly/react-core'
import { DefaultPlanSelect } from 'Plans/components/DefaultPlanSelect'
import { ajax, createReactWrapper } from 'utilities'
import * as alert from 'utilities/alert'
import type { Record as Plan } from 'Types'

import './DefaultPlanSelectCard.scss'

type Props = {
  plans: Array<Plan>,
  initialDefaultPlan: Plan | null,
  path: string
}

const DefaultPlanSelectCard = ({ plans, initialDefaultPlan, path: url }: Props): React.Node => {
  const NO_DEFAULT_PLAN: Plan = { id: -1, name: '(No default plan)' }

  const [defaultPlan, setDefaultPlan] = React.useState<Plan>(initialDefaultPlan ?? NO_DEFAULT_PLAN)

  const [isLoading, setIsLoading] = React.useState(false)

  const onSelectPlan = (plan: Plan) => {
    const body = plan.id >= 0 ? new URLSearchParams({ id: plan.id.toString() }) : undefined

    ajax(url, { method: 'POST', body })
      .then(data => {
        if (data.ok) {
          alert.notice('Default plan was updated')
          setDefaultPlan(plan)
        } else {
          if (data.status === 404) {
            alert.error("The selected plan doesn't exist.")
          } else {
            alert.error('Plan could not be updated')
          }
        }
      })
      .catch(err => {
        console.error(err)
        alert.error('An error ocurred. Please try again later.')
      })
      .finally(() => setIsLoading(false))

    setIsLoading(true)
  }

  const availablePlans = [NO_DEFAULT_PLAN, ...plans].filter(p => p.id !== defaultPlan.id)

  return (
    <Card id="default_plan_card">
      <CardBody>
        <Form onSubmit={e => e.preventDefault()}>
          <DefaultPlanSelect
            plan={defaultPlan}
            plans={availablePlans}
            onSelectPlan={onSelectPlan}
            isLoading={isLoading}
          />
        </Form>
      </CardBody>
    </Card>
  )
}

const DefaultPlanSelectWrapper = (props: Props, containerId: string): void => createReactWrapper(<DefaultPlanSelectCard {...props} />, containerId)

export { DefaultPlanSelectCard, DefaultPlanSelectWrapper }
