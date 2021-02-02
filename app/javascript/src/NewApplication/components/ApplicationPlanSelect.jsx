// @flow

import React, { useState } from 'react'

import {
  FormGroup,
  Select,
  SelectVariant,
  Button
} from '@patternfly/react-core'
import { toSelectOption, SelectOptionObject } from 'utilities/patternfly-utils'

import type { ApplicationPlan } from 'NewApplication/types'

type Props = {
  appPlan: ApplicationPlan | null,
  appPlans: ApplicationPlan[],
  onSelect: (ApplicationPlan | null) => void,
  createApplicationPlanPath: string,
  isDisabled?: boolean
}

const ApplicationPlanSelect = ({ appPlan, appPlans, onSelect, createApplicationPlanPath, isDisabled }: Props) => {
  const [expanded, setExpanded] = useState<boolean>(false)

  const showHint = !isDisabled && appPlans.length === 0

  const handleSelect = (_e, option: SelectOptionObject) => {
    setExpanded(false)

    const selectedPlan = appPlans.find(p => p.id.toString() === option.id)
    onSelect(selectedPlan || null)
  }

  return (
    <FormGroup
      isRequired
      label="Application plan"
      fieldId="cinstance_plan_id"
    >
      {appPlan && <input type="hidden" name="cinstance[plan_id]" value={appPlan.id} />}
      <Select
        id="cinstance_plan_id"
        variant={SelectVariant.typeahead}
        placeholderText="Select an application plan"
        // $FlowFixMe Flow wrong here
        selections={appPlan && new SelectOptionObject(appPlan)}
        onToggle={() => setExpanded(!expanded)}
        onSelect={handleSelect}
        isExpanded={expanded}
        onClear={() => onSelect(null)}
        aria-labelledby="application plan"
        isDisabled={isDisabled || appPlans.length === 0}
      >
        {/* $FlowFixMe Flow wrong here */}
        {appPlans.map(toSelectOption)}
      </Select>
      {showHint && (
        <p className="hint">
          {"An Application needs to subscribe to a Product's Application plan, and no Application plans exist for the selected Product. "}
          <Button component="a" variant="link" href={createApplicationPlanPath} isInline>
            Create a new Application plan
          </Button>
        </p>
      )}
    </FormGroup>
  )
}

export { ApplicationPlanSelect }
