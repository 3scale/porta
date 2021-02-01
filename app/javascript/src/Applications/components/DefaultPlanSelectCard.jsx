// @flow

import React, { useState } from 'react'
import { post } from 'utilities/ajax'

import {
  Form,
  FormGroup,
  Card,
  CardBody
} from '@patternfly/react-core'
import { DefaultPlanSelect } from 'Applications'
import { Spinner } from 'Common'

import type { Product, ApplicationPlan } from 'Applications/types'

import './DefaultPlanSelectCard.scss'

export type Props = {
  product: Product,
  initialDefaultPlan: ApplicationPlan | null,
  path: string
}

const NO_DEFAULT_PLAN: ApplicationPlan = { id: -1, name: '(No default plan)' }

const DefaultPlanSelectCard = ({ product, initialDefaultPlan, path }: Props) => {
  const [defaultPlan, setDefaultPlan] = useState<ApplicationPlan>(initialDefaultPlan ?? NO_DEFAULT_PLAN)

  const [isLoading, setIsLoading] = useState(false)

  const onSelectPlan = (plan: ApplicationPlan) => {
    const body = plan.id >= 0 ? new URLSearchParams({ id: plan.id.toString() }) : undefined
    const url = path.replace(':id', String(product.id))

    post(url, body)
      .then(data => {
        console.log(data)
        if (data.ok) {
          // $FlowFixMe
          $.flash('Default plan was updated')
          setDefaultPlan(plan)
        } else {
          if (data.status === 404) {
            // $FlowFixMe
            $.flash.error("The selected plan doesn't exist.")
          } else {
            // $FlowFixMe
            $.flash.error('Plan could not be updated')
          }
        }
      })
      .catch(err => {
        console.error(err)
        // $FlowFixMe
        $.flash.error('An error ocurred. Please try again later.')
      })
      .finally(() => setIsLoading(false))

    setIsLoading(true)
  }

  return (
    <Card id="default_plan_card">
      <CardBody>
        <Form onSubmit={e => e.preventDefault()}>
          <FormGroup
            label="Default plan"
            fieldId="application_plan_id"
            helperText="Default application plan (if any) is selected automatically upon service subscription."
          >
            {isLoading && <Spinner size='sm' className='pf-u-ml-md' />}
            <DefaultPlanSelect
              plan={defaultPlan}
              plans={[NO_DEFAULT_PLAN, ...product.appPlans].filter(p => p.id !== defaultPlan.id)} // Don't show the current default plan
              onSelectPlan={onSelectPlan}
              isDisabled={isLoading}
            />
          </FormGroup>
        </Form>
      </CardBody>
    </Card>
  )
}

export { DefaultPlanSelectCard }
