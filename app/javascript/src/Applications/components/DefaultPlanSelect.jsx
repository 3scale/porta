// @flow

import React, { useState } from 'react'

import {
  Select,
  SelectOption,
  SelectVariant
} from '@patternfly/react-core'
import { PlanSelectOptionObject } from 'Applications/utils'

import type { ApplicationPlan } from 'Applications/types'
type Props = {
  plan: ApplicationPlan,
  plans: ApplicationPlan[],
  onSelectPlan: (ApplicationPlan) => void,
  isDisabled?: boolean
}

const DefaultPlanSelect = ({ plan, plans, onSelectPlan, isDisabled = false }: Props) => {
  const [selection, setSelection] = useState<PlanSelectOptionObject | null>(new PlanSelectOptionObject(plan))
  const [isExpanded, setIsExpanded] = useState(false)

  const onSelect = (_e, newPlan: PlanSelectOptionObject) => {
    setSelection(newPlan)
    setIsExpanded(false)

    onSelectPlan(newPlan)
  }

  const onClear = () => {
    setSelection(null)
  }

  return (
    <Select
      id="default-plan-select"
      variant={SelectVariant.typeahead}
      aria-label="Select application plan"
      placeholderText="Select application plan"
      onToggle={() => setIsExpanded(!isExpanded)}
      onSelect={onSelect}
      onClear={onClear}
      isExpanded={isExpanded}
      isDisabled={isDisabled}
      selections={selection}
      isCreatable={false}
    >
      {plans.map(p => new PlanSelectOptionObject(p))
        .map(p => <SelectOption key={p.id} value={p} />)}
    </Select>
  )
}

export { DefaultPlanSelect }
