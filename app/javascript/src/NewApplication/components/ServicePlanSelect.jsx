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
      {'This account already subscribes to the service plan of the selected product. To change the account to subscribe to a different service plan for this product, go to '}
      <Button component="a" variant="link" href={serviceSubscriptionsPath} isInline>Service subscriptions</Button>.
    </p>
  ) : (
    <>
      <p className="hint">To subscribe the application to an application plan of this product, you must subscribe this account to a service plan linked to this product.</p>
      {servicePlans && servicePlans.length === 0 && (
        <p className="hint">
          {'No service plans exist for the selected product. '}
          <Button component="a" variant="link" href={createServicePlanPath} isInline>
            Create a new service plan
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
      isDisabled={isDisabled || isPlanContracted}
      isRequired={!isPlanContracted}
      isClearable={false}
    />
  )
}

export { ServicePlanSelect }
