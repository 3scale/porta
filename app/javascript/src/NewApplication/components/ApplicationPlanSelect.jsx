// @flow

import * as React from 'react'

import { Button } from '@patternfly/react-core'
import { Select } from 'Common'

import type { ApplicationPlan, Product } from 'NewApplication/types'

type Props = {
  appPlan: ApplicationPlan | null,
  product: Product | null,
  onSelect: (ApplicationPlan | null) => void,
  createApplicationPlanPath: string
}

const ApplicationPlanSelect = ({ appPlan, product, onSelect, createApplicationPlanPath }: Props): React.Node => {
  const appPlans = product ? product.appPlans : []
  const showHint = product && appPlans.length === 0

  const hint = (
    <p className="hint">
      {"An Application needs to subscribe to a Product's Application plan, and no Application plans exist for the selected Product. "}
      <Button component="a" variant="link" href={createApplicationPlanPath} isInline>
        Create a new Application plan
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
