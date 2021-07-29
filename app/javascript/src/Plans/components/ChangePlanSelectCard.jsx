// @flow

import * as React from 'react'
import { useState } from 'react'

import { createReactWrapper } from 'utilities'
import {
  ActionGroup,
  Button,
  Form,
  Card,
  CardBody,
  CardHeader
} from '@patternfly/react-core'
import { Select as SelectFormGroup } from 'Common'
import { CSRFToken } from 'utilities'

import type { Plan } from 'Types'

import './ChangePlanSelectCard.scss'

type Props = {
  applicationPlans: Plan[],
  path: string
}

const ChangePlanSelectCard = ({ applicationPlans, path }: Props): React.Node => {
  const [plan, setPlan] = useState<Plan | null>(null)

  const plans = plan ? applicationPlans.map(p => ({ ...p, disabled: p.id === plan.id })) : applicationPlans

  return (
    <Card id="change_plan_card">
      <CardHeader>
        <h3>Change plan</h3>
      </CardHeader>
      <CardBody>
        <Form
          acceptCharset="UTF-8"
          method="post"
          action={path}
        >
          <CSRFToken />
          <input type="hidden" name="utf8" value="✓" />
          <input type="hidden" name="_method" value="put" />

          {/* $FlowIgnore[prop-missing] description is optional */}
          <SelectFormGroup
            label=""
            // $FlowIgnore[incompatible-type] plan is either Plan or null
            item={plan}
            // $FlowIgnore[incompatible-type] id can be either number or string
            items={plans}
            onSelect={setPlan}
            fieldId="cinstance_plan_id"
            name="cinstance[plan_id]"
            placeholderText="Select plan"
          />

          <ActionGroup>
            <Button
              variant="primary"
              type="submit"
              isDisabled={!plan}
            >
              Change plan
            </Button>
          </ActionGroup>
        </Form>
      </CardBody>
    </Card>
  )
}

const ChangePlanSelectCardWrapper = (props: Props, containerId: string): void => createReactWrapper(<ChangePlanSelectCard {...props} />, containerId)

export { ChangePlanSelectCard, ChangePlanSelectCardWrapper }
