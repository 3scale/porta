// @flow

import * as React from 'react'

import { createReactWrapper } from 'utilities'

import {
  ActionGroup,
  Button,
  Form,
  Card,
  CardBody
} from '@patternfly/react-core'
import { Select as SelectFormGroup } from 'Common/components/Select'
import { HelperText, HelperTextItem } from 'Common/components/HelperText'
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
  const [defaultPlan, setDefaultPlan] = React.useState<Plan | null>(initialDefaultPlan ?? NO_DEFAULT_PLAN)

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
          {/* $FlowIgnore[incompatible-type-arg] id can be either number or string */}
          <SelectFormGroup
            label="Default plan"
            // $FlowIgnore[incompatible-type] plan is either Plan or null
            item={defaultPlan}
            // $FlowIgnore[incompatible-type] id can be either number or string
            items={plans}
            onSelect={setDefaultPlan}
            fieldId="id"
            name="id"
            placeholderText={defaultPlan ? defaultPlan.name : 'Select application plan'}
          />
          <ActionGroup>
            <Button
              variant="primary"
              type="submit"
              isDisabled={!defaultPlan}
              >
              Change plan
            </Button>
          </ActionGroup>
        </Form>
        <HelperText>
          <HelperTextItem>
            Default application plan (if any) is selected automatically upon service subscription.
          </HelperTextItem>
        </HelperText>
      </CardBody>
    </Card>
  )
}

const DefaultPlanSelectCardWrapper = (props: Props, containerId: string): void => createReactWrapper(<DefaultPlanSelectCard {...props} />, containerId)

export { DefaultPlanSelectCard, DefaultPlanSelectCardWrapper }
