// @flow

import React, { useState } from 'react'

import { Select, SelectVariant } from '@patternfly/react-core'
import { SelectOptionObject, toSelectOption } from 'utilities/patternfly-utils'

import './DefaultPlanSelect.scss'

import type { ApplicationPlan } from 'Applications/types'

type Props = {
  plan: ApplicationPlan,
  plans: ApplicationPlan[],
  onSelectPlan: (ApplicationPlan) => void,
  isDisabled?: boolean
}

const DefaultPlanSelect = ({ plan, plans, onSelectPlan, isDisabled = false }: Props) => {
  // $FlowFixMe Flow is wrong here
  const [selection, setSelection] = useState<SelectOptionObject | null>(new SelectOptionObject(plan))
  const [isExpanded, setIsExpanded] = useState(false)

  const onSelect = (_e, option: SelectOptionObject) => {
    setSelection(option)
    setIsExpanded(false)

    const newPlan = plans.find(p => p.id.toString() === option.id)
    if (newPlan) {
      onSelectPlan(newPlan)
    }
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
      {/* $FlowFixMe Flow is wrong here */}
      {plans.map(toSelectOption)}
    </Select>
  )
}

export { DefaultPlanSelect }
