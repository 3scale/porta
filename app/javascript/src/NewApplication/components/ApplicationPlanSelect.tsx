import { Button } from '@patternfly/react-core'

import { Select } from 'Common/components/Select'

import type { Plan, Product } from 'NewApplication/types'

interface Props {
  appPlan: Plan | null;
  product: Product | null;
  onSelect: (appPlan: Plan | null) => void;
  createApplicationPlanPath: string;
}

const ApplicationPlanSelect: React.FunctionComponent<Props> = ({
  appPlan,
  product,
  onSelect,
  createApplicationPlanPath
}) => {
  const appPlans = product ? product.appPlans : []
  const showHint = product && appPlans.length === 0

  const hint = (
    <p className="hint">
      {"An application must subscribe to a product's application plan. No application plans exist for the selected product. "}
      <Button isInline component="a" href={createApplicationPlanPath} variant="link">
        Create a new application plan
      </Button>
    </p>
  )

  return (
    <Select
      isRequired
      fieldId="cinstance_plan_id"
      hint={showHint && hint}
      isDisabled={product === null || !appPlans.length}
      item={appPlan}
      items={appPlans}
      label="Application plan"
      name="cinstance[plan_id]"
      placeholderText="Select an application plan"
      onSelect={onSelect}
    />
  )
}

export type { Props }
export { ApplicationPlanSelect }
