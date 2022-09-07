import * as React from 'react';

import {
  ActionGroup,
  Button,
  Form,
  Card,
  CardBody
} from '@patternfly/react-core'
import { Select as SelectFormGroup } from 'Common/components/Select'
import { HelperText, HelperTextItem } from 'Common/components/HelperText'
import { createReactWrapper, CSRFToken } from 'utilities'

import type { Record as Plan } from 'Types'

import './DefaultPlanSelectCard.scss'

type Props = {
  plans: Array<Plan>,
  initialDefaultPlan: Plan | null,
  path: string
};

const DefaultPlanSelectCard = (
  {
    plans,
    initialDefaultPlan,
    path: url,
  }: Props,
): React.ReactElement => {
  const NO_DEFAULT_PLAN: Plan = { id: '', name: 'No plan selected' };

  const [defaultPlan, setDefaultPlan] = React.useState<Plan | null>(initialDefaultPlan ?? NO_DEFAULT_PLAN)

  const availablePlans = [NO_DEFAULT_PLAN, ...plans]

  // TODO: in PF4, "isDisabled" behaviour is replaced by ticking the selected item. Remove this after upgrading.
  const mappedPlans = defaultPlan ? availablePlans.map(p => ({ ...p, disabled: p.id === defaultPlan.id })) : availablePlans

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
            items={mappedPlans}
            onSelect={setDefaultPlan}
            fieldId="id"
            name="id"
            placeholderText={defaultPlan ? defaultPlan.name : 'Select plan'}
          />
          <ActionGroup>
            <Button
              variant="primary"
              type="submit"
              isDisabled={!defaultPlan || defaultPlan.id === initialDefaultPlan?.id || (defaultPlan.id === NO_DEFAULT_PLAN.id && !initialDefaultPlan)}
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

const DefaultPlanSelectCardWrapper = (props: Props, containerId: string): void => createReactWrapper(<DefaultPlanSelectCard {...props} />, containerId)

export { DefaultPlanSelectCard, DefaultPlanSelectCardWrapper }
