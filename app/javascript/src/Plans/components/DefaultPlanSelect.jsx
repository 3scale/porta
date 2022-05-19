// @flow

import * as React from 'react'

import { Select } from 'Common'
import { toSelectOption } from 'utilities'

import './DefaultPlanSelect.scss'

import type { Record as Plan } from 'Types'

type Props = {
  plan: Plan,
  plans: Plan[],
  onSelectPlan: Plan => void,
  isLoading?: boolean
}

const DefaultPlanSelect = ({ plan, plans, onSelectPlan, isLoading = false }: Props): React.Node => {
  const onSelect = (newPlan: Plan | null) => {
    if (newPlan) {
      onSelectPlan(newPlan)
    }
  }

  return (
    // $FlowIssue[prop-missing] missing props are optional
    // $FlowIssue[incompatible-type-arg] should not complain about plan having id as number, since Record has union "number | string"
    <Select
      // $FlowFixMe[incompatible-type] this is nonsense
      item={plan}
      items={plans}
      onSelect={onSelect}
      label="Default plan"
      fieldId="application_plan_id"
      name=""
      placeholderText="Select application plan"
      isDisabled={isLoading}
      aria-label="Select application plan"
      helperText="Default application plan (if any) is selected automatically upon service subscription."
      isClearable={false}
      isLoading={isLoading}
    >
      {/* $FlowIssue[prop-missing] missing props are optional */}
      {/* $FlowIssue[incompatible-call] should not complain about plan having id as number, since Record has union "number | string" */}
      {plans.map(toSelectOption)}
    </Select>
  )
}

export { DefaultPlanSelect }
