// @flow

import * as React from 'react'

import { Button } from '@patternfly/react-core'
import { Select } from 'Common'

import type { ServicePlan } from 'NewApplication/types'

type Props = {
  servicePlan: ServicePlan | null,
  servicePlans: ServicePlan[] | null,
  onSelect: (ServicePlan | null) => void,
  isPlanContracted: boolean,
  serviceSubscriptionsPath: string,
  createServicePlanPath: string,
  isDisabled?: boolean
}

const ServicePlanSelect = ({
  isDisabled,
  isPlanContracted,
  servicePlans,
  servicePlan,
  onSelect,
  serviceSubscriptionsPath,
  createServicePlanPath
}: Props): React.Node => {
  const hint = isPlanContracted ? (
    <p className="hint">
      {'This Account already subscribes to the selected Product’s Service plan. If you want this Account to subscribe to a different Service plan for this Product go to '}
      <Button component="a" variant="link" href={serviceSubscriptionsPath} isInline>Service subscriptions</Button>.
    </p>
  ) : (
    <>
      <p className="hint">In order to subscribe the Application to a Product’s Application plan, this Account needs to subscribe to a Product’s Service plan.</p>
      {servicePlans && servicePlans.length === 0 && (
        <p className="hint">
          {'No Service plans exist for the selected Product. '}
          <Button component="a" variant="link" href={createServicePlanPath} isInline>
            Create a new Service plan
          </Button>
        </p>)
      }
    </>
  )

  return (
    // $FlowIssue[incompatible-type-arg] It should not complain since Record.id has union "number | string"
    // $FlowIssue[prop-missing] description is optional
    <Select
      // $FlowIssue[incompatible-type] ServicePlan implements Record
      item={servicePlan}
      items={servicePlans || []}
      onSelect={onSelect}
      label="Service plan"
      fieldId="cinstance_service_plan_id"
      name="cinstance[service_plan_id]"
      placeholderText="Select a service plan"
      hint={hint}
      isDisabled={isDisabled}
      isRequired={!isPlanContracted}
      isClearable={false}
    />
  )
}

export { ServicePlanSelect }
