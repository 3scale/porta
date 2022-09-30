
import { Button } from '@patternfly/react-core'
import { Select } from 'Common'

import type { ServicePlan } from 'NewApplication/types'

type Props = {
  servicePlan: ServicePlan | null,
  servicePlans: ServicePlan[] | null,
  onSelect: (arg1: ServicePlan | null) => void,
  isPlanContracted: boolean,
  serviceSubscriptionsPath: string,
  createServicePlanPath: string,
  isDisabled?: boolean
};

const ServicePlanSelect: React.FunctionComponent<Props> = ({
  isDisabled,
  isPlanContracted,
  servicePlans,
  servicePlan,
  onSelect,
  serviceSubscriptionsPath,
  createServicePlanPath
}) => {
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
    <Select
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

export { ServicePlanSelect, Props }
