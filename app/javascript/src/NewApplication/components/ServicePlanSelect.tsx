import { Button } from '@patternfly/react-core'
import { Select } from 'Common/components/Select'

import type { Plan } from 'NewApplication/types'

interface Props {
  servicePlan: Plan | null;
  servicePlans: Plan[] | null;
  onSelect: (servicePlan: Plan | null) => void;
  isPlanContracted: boolean;
  serviceSubscriptionsPath: string;
  createServicePlanPath: string;
  isDisabled?: boolean;
}

const ServicePlanSelect: React.FunctionComponent<Props> = ({
  isDisabled = false,
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
      <Button isInline component="a" href={serviceSubscriptionsPath} variant="link">Service subscriptions</Button>.
    </p>
  ) : (
    <>
      <p className="hint">To subscribe the application to an application plan of this product, you must subscribe this account to a service plan linked to this product.</p>
      {servicePlans && servicePlans.length === 0 && (
        <p className="hint">
          {'No service plans exist for the selected product. '}
          <Button isInline component="a" href={createServicePlanPath} variant="link">
            Create a new service plan
          </Button>
        </p>
      )}
    </>
  )

  return (
    <Select
      fieldId="cinstance_service_plan_id"
      hint={hint}
      isClearable={false}
      isDisabled={isDisabled || isPlanContracted}
      isRequired={!isPlanContracted}
      item={servicePlan}
      items={servicePlans ?? []}
      label="Service plan"
      name="cinstance[service_plan_id]"
      placeholderText="Select a service plan"
      onSelect={onSelect}
    />
  )
}

export { ServicePlanSelect, Props }
