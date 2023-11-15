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

import type { IRecord as Plan } from 'Types'

import './ChangePlanSelect.scss'

interface Props {
  applicationPlans: Plan[];
  path: string;
}

const ChangePlanSelect: React.FunctionComponent<Props> = ({
  applicationPlans,
  path
}) => {
  const [plan, setPlan] = useState<Plan | null>(null)

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
            items={applicationPlans}
            label={<h3>Change plan</h3>}
            name="cinstance[plan_id]"
            ouiaId="Change plan"
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
const ChangePlanSelectCardWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ChangePlanSelect {...props} />, containerId) }

export type { Props }
export { ChangePlanSelect, ChangePlanSelectCardWrapper }
