// @flow

import React, { useState } from 'react'

import {
  FormGroup,
  Select,
  SelectVariant
} from '@patternfly/react-core'
import { toSelectOption, SelectOptionObject } from 'utilities/patternfly-utils'

import type { ServicePlan } from 'NewApplication/types'

type Props = {
  servicePlan: ServicePlan | null,
  servicePlans: ServicePlan[],
  onSelect: (ServicePlan | null) => void,
  isDisabled?: boolean,
  isRequired?: boolean
}

const ServicePlanSelect = ({ isDisabled, isRequired, servicePlans, servicePlan, onSelect }: Props) => {
  const [expanded, setExpanded] = useState(false)

  const handleSelect = (_e, option: SelectOptionObject) => {
    setExpanded(false)

    const selectedPlan = servicePlans.find(p => p.id.toString() === option.id)
    onSelect(selectedPlan || null)
  }

  return (
    <FormGroup
      isRequired={isRequired}
      label="Service plan"
      fieldId="cinstance_service_plan_id"
    >
      {servicePlan && <input type="hidden" name="cinstance[service_plan_id]" value={servicePlan.id} />}
      <Select
        id="cinstance_service_plan_id"
        variant={SelectVariant.typeahead}
        placeholderText="Select a service plan"
        // $FlowFixMe Flow wrong here
        selections={servicePlan && new SelectOptionObject(servicePlan)}
        onToggle={() => setExpanded(!expanded)}
        onSelect={handleSelect}
        isExpanded={expanded}
        onClear={() => onSelect(null)}
        aria-labelledby="service plan"
        isDisabled={isDisabled}
      >
        {/* $FlowFixMe Flow wrong here */}
        {servicePlans.map(toSelectOption)}
      </Select>
    </FormGroup>
  )
}

export { ServicePlanSelect }
