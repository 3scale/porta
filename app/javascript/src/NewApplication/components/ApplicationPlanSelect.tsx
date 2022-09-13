import * as React from 'react'

import { Button } from '@patternfly/react-core'
import { Select } from 'Common'

import type { ApplicationPlan, Product } from 'NewApplication/types'

type Props = {
  appPlan: ApplicationPlan | null,
  product: Product | null,
  onSelect: (arg1: ApplicationPlan | null) => void,
  createApplicationPlanPath: string
};

const ApplicationPlanSelect = (
  {
    appPlan,
    product,
    onSelect,
    createApplicationPlanPath
  }: Props
): React.ReactElement => {
  const appPlans = product ? product.appPlans : []
  const showHint = product && appPlans.length === 0

  const hint = (
    <p className="hint">
      {"An application must subscribe to a product's application plan. No application plans exist for the selected product. "}
      <Button component="a" variant="link" href={createApplicationPlanPath} isInline>
        Create a new application plan
      </Button>
    </p>
  )

  return (
    // $FlowIssue[incompatible-type-arg] It should not complain since Record.id has union "number | string"
    // $FlowIssue[prop-missing] description is optional
    <Select
      // $FlowIssue[incompatible-type] ServicePlan implements Record
      item={appPlan}
      items={appPlans}
      onSelect={onSelect}
      label="Application plan"
      fieldId="cinstance_plan_id"
      name="cinstance[plan_id]"
      placeholderText="Select an application plan"
      hint={showHint && hint}
      isDisabled={product === null || !appPlans.length}
      isRequired
    />
  )
}

export { ApplicationPlanSelect }
