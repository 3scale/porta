// @flow

import * as React from 'react'

import { Button } from '@patternfly/react-core'
import { Select } from 'Common'

import type { ServicePlan } from 'NewApplication/types'

type Props = {
  servicePlan: ServicePlan | null,
  servicePlans: ServicePlan[],
  onSelect: (ServicePlan | null) => void,
  isPlanContracted: boolean,
  showHint: boolean,
  serviceSubscriptionsPath: string,
  isDisabled?: boolean
}

const ServicePlanSelect = ({ showHint, isDisabled, isPlanContracted, servicePlans, servicePlan, onSelect, serviceSubscriptionsPath }: Props) => {
  const hint = isPlanContracted ? (
    <p className="hint">
      {'This Account already subscribes to the selected Product’s Service plan. If you want this Account to subscribe to a different Service plan for this Product go to '}
      <Button component="a" variant="link" href={serviceSubscriptionsPath} isInline>Service subscriptions</Button>.
    </p>
  ) : (
    <p className="hint">In order to subscribe the Application to a Product’s Application plan, this Account needs to subscribe to a Product’s Service plan.</p>
  )

  return (
    <Select
      // $FlowFixMe $FlowIssue It should not complain since Record.id has union "number | string"
      item={servicePlan}
      // $FlowFixMe $FlowIssue It should not complain since Record.id has union "number | string"
      items={servicePlans}
      onSelect={onSelect}
      label="Service plan"
      fieldId="cinstance_service_plan_id"
      name="cinstance[service_plan_id]"
      placeholderText="Select a service plan"
      hint={hint}
      isDisabled={isDisabled}
      isRequired={!isPlanContracted}
    />
  )
}

export { ServicePlanSelect }
