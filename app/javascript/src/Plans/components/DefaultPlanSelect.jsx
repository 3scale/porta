// @flow

import * as React from 'react'
import { Select, SelectVariant } from '@patternfly/react-core'
import {
  toSelectOptionObject,
  toSelectOption,
  SelectOptionObject,
  handleOnFilter
} from 'utilities'

import './DefaultPlanSelect.scss'

import type { Plan } from 'Types'

type Props = {
  plan: Plan,
  plans: Plan[],
  onSelectPlan: Plan => void,
  isDisabled?: boolean
}

const DefaultPlanSelect = ({ plan, plans, onSelectPlan, isDisabled = false }: Props): React.Node => {
  // $FlowIssue[prop-missing] description is optional
  // $FlowIssue[incompatible-call] should not complain about plan having id as number, since Record has union "number | string"
  const [selection, setSelection] = React.useState<SelectOptionObject | null>(toSelectOptionObject(plan))
  const [isExpanded, setIsExpanded] = React.useState(false)

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
      // $FlowIssue[prop-missing] description is optional
      // $FlowIssue[incompatible-call] should not complain about plan having id as number, since Record has union "number | string"
      onFilter={handleOnFilter(plans)}
    >
      {/* $FlowIssue[prop-missing] description is optional */}
      {/* $FlowIssue[incompatible-call] should not complain about plan having id as number, since Record has union "number | string" */}
      {plans.map(toSelectOption)}
    </Select>
  )
}

export { DefaultPlanSelect }
