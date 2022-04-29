// @flow

import * as React from 'react'

import { createReactWrapper } from 'utilities'
// import { DefaultPlanSelect } from 'Plans'
import {
  ActionGroup,
  Button,
  Form,
  Card,
  CardBody
} from '@patternfly/react-core'
import { Select as SelectFormGroup } from 'Common'
import { CSRFToken } from 'utilities'

import type { Product, Plan } from 'Types'

import './DefaultPlanSelectCard.scss'

type Props = {
  product: Product,
  initialDefaultPlan: Plan | null,
  path: string
}

const NO_DEFAULT_PLAN: Plan = { id: -1, name: '(No default plan)' }

const DefaultPlanSelectCard = ({ product, initialDefaultPlan, path }: Props): React.Node => {
  const [defaultPlan, setDefaultPlan] = React.useState<Plan>(initialDefaultPlan ?? NO_DEFAULT_PLAN)

  const availablePlans = [NO_DEFAULT_PLAN, ...product.appPlans]

  // TODO: in PF4, "isDisabled" behaviour is replaced by ticking the selected item. Remove this after upgrading.
  const plans = defaultPlan ? availablePlans.map(p => ({ ...p, disabled: p.id === defaultPlan.id })) : availablePlans

  const url = path.replace(':id', String(product.id))

  return (
    <Card id="default_plan_card">
      <CardBody>
        <Form
          acceptCharset="UTF-8"
          method="post"
          action={url}
        >
          <CSRFToken />
          <input type="hidden" name="utf8" value="✓" />

          {/* $FlowIgnore[prop-missing] description is optional */}
          <SelectFormGroup
            label={<h3>Change plan</h3>}
            // $FlowIgnore[incompatible-type] plan is either Plan or null
            item={defaultPlan}
            // $FlowIgnore[incompatible-type] id can be either number or string
            items={plans}
            onSelect={setDefaultPlan}
            fieldId="id"
            name="id"
            placeholderText={defaultPlan.name}
          />

          <ActionGroup>
            <Button
              variant="primary"
              type="submit"
              // isDisabled={!plan}
            >
              Change plan
            </Button>
          </ActionGroup>
        </Form>
      </CardBody>
    </Card>
  )
}

const DefaultPlanSelectCardWrapper = (props: Props, containerId: string): void => createReactWrapper(<DefaultPlanSelectCard {...props} />, containerId)

export { DefaultPlanSelectCard, DefaultPlanSelectCardWrapper }

// import * as React from 'react'

// import { Form, Card, CardBody } from '@patternfly/react-core'
// import { DefaultPlanSelect } from 'Plans'
// import { ajax, createReactWrapper } from 'utilities'
// import * as alert from 'utilities/alert'

// import type { Product, Plan } from 'Types'

// import './DefaultPlanSelectCard.scss'

// type Props = {
//   product: Product,
//   initialDefaultPlan: Plan | null,
//   path: string
// }

// const NO_DEFAULT_PLAN: Plan = { id: -1, name: '(No default plan)' }

// const DefaultPlanSelectCard = ({ product, initialDefaultPlan, path }: Props): React.Node => {
//   const [defaultPlan, setDefaultPlan] = React.useState<Plan>(initialDefaultPlan ?? NO_DEFAULT_PLAN)

//   const [isLoading, setIsLoading] = React.useState(false)

//   const onSelectPlan = (plan: Plan) => {
//     const body = plan.id >= 0 ? new URLSearchParams({ id: plan.id.toString() }) : undefined
//     const url = path.replace(':id', String(product.id))

//     ajax(url, { method: 'POST', body })
//       .then(data => {
//         if (data.ok) {
//           alert.notice('Default plan was updated')
//           setDefaultPlan(plan)
//         } else {
//           if (data.status === 404) {
//             alert.error("The selected plan doesn't exist.")
//           } else {
//             alert.error('Plan could not be updated')
//           }
//         }
//       })
//       .catch(err => {
//         console.error(err)
//         alert.error('An error ocurred. Please try again later.')
//       })
//       .finally(() => setIsLoading(false))

//     setIsLoading(true)
//   }

//   const availablePlans = [NO_DEFAULT_PLAN, ...product.appPlans].filter(p => p.id !== defaultPlan.id)

//   return (
//     <Card id="default_plan_card">
//       <CardBody>
//         <Form onSubmit={e => e.preventDefault()}>
//           <DefaultPlanSelect
//             plan={defaultPlan}
//             plans={availablePlans}
//             onSelectPlan={onSelectPlan}
//             isLoading={isLoading}
//           />
//         </Form>
//       </CardBody>
//     </Card>
//   )
// }

// const DefaultPlanSelectWrapper = (props: Props, containerId: string): void => createReactWrapper(<DefaultPlanSelectCard {...props} />, containerId)

// export { DefaultPlanSelectCard, DefaultPlanSelectWrapper }
