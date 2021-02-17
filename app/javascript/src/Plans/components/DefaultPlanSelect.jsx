// @flow

import React, { useState } from 'react'
import { Select, SelectVariant } from '@patternfly/react-core'
import { toSelectOptionObject, toSelectOption, SelectOptionObject } from 'utilities/patternfly-utils'
import './DefaultPlanSelect.scss'
import type { ApplicationPlan } from 'Types'

type Props = {
  plan: ApplicationPlan,
  plans: ApplicationPlan[],
  onSelectPlan: ApplicationPlan => void,
  isDisabled?: boolean
}

const DefaultPlanSelect = ({ plan, plans, onSelectPlan, isDisabled = false }: Props) => {
  // $FlowFixMe should not complain about plan having id as number, since Record has union "number | string"
  const [selection, setSelection] = useState<SelectOptionObject | null>(toSelectOptionObject(plan))
  const [isExpanded, setIsExpanded] = useState(false)

  const onSelect = (_e, option: SelectOptionObject) => {
    setSelection(option)
    setIsExpanded(false)

    const newPlan = plans.find(p => p.id.toString() === option.id)
    if (newPlan) {
      onSelectPlan(newPlan)
    }
  }

  return (
    <Select
      id="default-plan-select"
      variant={SelectVariant.typeahead}
      aria-label="Select application plan"
      placeholderText="Select application plan"
      onToggle={() => setIsExpanded(!isExpanded)}
      onSelect={onSelect}
      onClear={() => setSelection(null)}
      isExpanded={isExpanded}
      isDisabled={isDisabled}
      selections={selection}
      isCreatable={false}
    >
      {/* $FlowFixMe Flow is wrong here */}
      {plans.map(toSelectOption)}
    </Select>
  )
}

export { DefaultPlanSelect }
