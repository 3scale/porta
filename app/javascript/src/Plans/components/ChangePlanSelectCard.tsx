import { useState } from 'react'
import {
  ActionGroup,
  Button,
  Card,
  CardBody,
  Form
} from '@patternfly/react-core'
import { Select as SelectFormGroup } from 'Common/components/Select'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { CSRFToken } from 'utilities/CSRFToken'

import type { Record as Plan } from 'Types'

import './ChangePlanSelectCard.scss'

type Props = {
  applicationPlans: Plan[],
  path: string
}

const ChangePlanSelectCard: React.FunctionComponent<Props> = ({
  applicationPlans,
  path
}) => {
  const [plan, setPlan] = useState<Plan | null>(null)

  // TODO: in PF4, "isDisabled" behaviour is replaced by ticking the selected item. Remove this after upgrading.
  const plans = plan ? applicationPlans.map(p => ({ ...p, disabled: p.id === plan.id })) : applicationPlans

  return (
    <Card id="change_plan_card">
      <CardBody>
        <Form
          acceptCharset="UTF-8"
          action={path}
          method="post"
        >
          <CSRFToken />
          <input name="utf8" type="hidden" value="✓" />
          <input name="_method" type="hidden" value="put" />

          <SelectFormGroup
            fieldId="cinstance_plan_id"
            item={plan}
            items={plans}
            label={<h3>Change plan</h3>}
            name="cinstance[plan_id]"
            placeholderText="Select plan"
            onSelect={setPlan}
          />

          <ActionGroup>
            <Button
              isDisabled={!plan}
              type="submit"
              variant="primary"
            >
              Change plan
            </Button>
          </ActionGroup>
        </Form>
      </CardBody>
    </Card>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ChangePlanSelectCardWrapper = (props: Props, containerId: string): void => createReactWrapper(<ChangePlanSelectCard {...props} />, containerId)

export { ChangePlanSelectCard, ChangePlanSelectCardWrapper, Props }
