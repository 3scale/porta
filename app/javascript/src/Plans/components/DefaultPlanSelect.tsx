import { useState } from 'react'
import {
  ActionGroup,
  Button,
  Flex,
  FlexItem,
  Form
} from '@patternfly/react-core'

import { Select as SelectFormGroup } from 'Common/components/Select'
import { CSRFToken } from 'utilities/CSRFToken'

import type { FunctionComponent } from 'react'
import type { IRecord as Plan } from 'Types'

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

  const submitDisabled = !defaultPlan || defaultPlan.id === initialDefaultPlan?.id
    || (defaultPlan.id === NO_DEFAULT_PLAN.id && !initialDefaultPlan)

  return (
    <Form
      isWidthLimited
      acceptCharset="UTF-8"
      action={url}
      method="post"
    >
      <CSRFToken />
      <input name="utf8" type="hidden" value="✓" />

      <Flex alignItems={{ default: 'alignItemsFlexEnd' }} direction={{ default: 'row' }}>
        <FlexItem flex={{ default: 'flex_2' }}>
          <SelectFormGroup
            fieldId="id"
            item={defaultPlan}
            items={availablePlans}
            label="Default plan"
            name="id"
            ouiaId="default-plan-select"
            placeholderText={defaultPlan ? defaultPlan.name : 'Select plan'}
            onSelect={setDefaultPlan}
          />
        </FlexItem>
        <FlexItem flex={{ default: 'flex_1' }}>
          <ActionGroup>
            <Button
              isDisabled={submitDisabled}
              ouiaId="default-plan-submit"
              type="submit"
              variant="primary"
            >
              Change plan
            </Button>
          </ActionGroup>
        </FlexItem>
      </Flex>
    </Form>
  )
}

export type { Props }
export { DefaultPlanSelectCard }
