// @flow

import React, { useState } from 'react'

import {
  FormGroup,
  Select,
  SelectVariant,
  Button
} from '@patternfly/react-core'
import { toSelectOption, toSelectOptionObject, SelectOptionObject } from 'utilities/patternfly-utils'

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
  const [expanded, setExpanded] = useState(false)

  const hint = isPlanContracted ? (
    <p className="hint">
      {'This Account already subscribes to the selected Product’s Service plan. If you want this Account to subscribe to a different Service plan for this Product go to '}
      <Button component="a" variant="link" href={serviceSubscriptionsPath} isInline>Service subscriptions</Button>.
    </p>
  ) : (
    <p className="hint">In order to subscribe the Application to a Product’s Application plan, this Account needs to subscribe to a Product’s Service plan.</p>
  )

  const handleSelect = (_e, option: SelectOptionObject) => {
    setExpanded(false)

    const selectedPlan = servicePlans.find(p => p.id.toString() === option.id)
    onSelect(selectedPlan || null)
  }

  return (
    <FormGroup
      isRequired={!isPlanContracted}
      label="Service plan"
      fieldId="cinstance_service_plan_id"
    >
      {servicePlan && <input type="hidden" name="cinstance[service_plan_id]" value={servicePlan.id} />}
      <Select
        id="cinstance_service_plan_id"
        variant={SelectVariant.typeahead}
        placeholderText="Select a service plan"
        // $FlowFixMe $FlowIssue It should not complain since Record.id has union "number | string"
        selections={servicePlan && toSelectOptionObject(servicePlan)}
        onToggle={() => setExpanded(!expanded)}
        onSelect={handleSelect}
        isExpanded={expanded}
        onClear={() => onSelect(null)}
        aria-labelledby="service plan"
        isDisabled={isDisabled}
      >
        {/* $FlowFixMe $FlowIssue It should not complain since Record.id has union "number | string" */}
        {servicePlans.map(toSelectOption)}
      </Select>
      {showHint && hint}
    </FormGroup>
  )
}

export { ServicePlanSelect }
