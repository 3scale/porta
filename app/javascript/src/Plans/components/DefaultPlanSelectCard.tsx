import { useState } from 'react'
import {
  ActionGroup,
  Button,
  Card,
  CardBody,
  Form
} from '@patternfly/react-core'

import { Select as SelectFormGroup } from 'Common/components/Select'
import { HelperText, HelperTextItem } from 'Common/components/HelperText'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { CSRFToken } from 'utilities/CSRFToken'

import type { FunctionComponent } from 'react'
import type { IRecord as Plan } from 'Types'

import './DefaultPlanSelectCard.scss'

interface Props {
  plans: Plan[];
  initialDefaultPlan: Plan | null;
  path: string;
}

const DefaultPlanSelectCard: FunctionComponent<Props> = ({
  plans,
  initialDefaultPlan,
  path: url
}) => {
  const NO_DEFAULT_PLAN: Plan = { id: -1, name: 'No plan selected' } as const

  const [defaultPlan, setDefaultPlan] = useState<Plan | null>(initialDefaultPlan ?? NO_DEFAULT_PLAN)

  const availablePlans = [NO_DEFAULT_PLAN, ...plans]

  // TODO: in PF4, "isDisabled" behaviour is replaced by ticking the selected item. Remove this after upgrading.
  const mappedPlans = defaultPlan ? availablePlans.map(p => ({ ...p, disabled: p.id === defaultPlan.id })) : availablePlans

  return (
    <Card id="default_plan_card">
      <CardBody>
        <Form
          acceptCharset="UTF-8"
          action={url}
          method="post"
        >
          <CSRFToken />
          <input name="utf8" type="hidden" value="✓" />

          <SelectFormGroup
            fieldId="id"
            item={defaultPlan}
            items={mappedPlans}
            label="Default plan"
            name="id"
            placeholderText={defaultPlan ? defaultPlan.name : 'Select plan'}
            onSelect={setDefaultPlan}
          />
          <ActionGroup>
            <Button
              isDisabled={!defaultPlan || defaultPlan.id === initialDefaultPlan?.id || (defaultPlan.id === NO_DEFAULT_PLAN.id && !initialDefaultPlan)}
              type="submit"
              variant="primary"
            >
              Change plan
            </Button>
          </ActionGroup>
        </Form>
        <HelperText>
          <HelperTextItem>
            If an application plan is set as default, 3scale sets this plan upon service subscription.
          </HelperTextItem>
        </HelperText>
      </CardBody>
    </Card>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const DefaultPlanSelectCardWrapper = (props: Props, containerId: string): void => { createReactWrapper(<DefaultPlanSelectCard {...props} />, containerId) }

export { DefaultPlanSelectCard, DefaultPlanSelectCardWrapper, Props }
