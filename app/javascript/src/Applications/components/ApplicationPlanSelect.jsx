import React from 'react'

import {
  FormSelect,
  Button
} from '@patternfly/react-core'
import { toFormSelectOption } from 'utilities/patternfly-utils'

import type { ApplicationPlan } from 'Applications/types'

type Props = {
  appPlans: ApplicationPlan[],
  appPlan: ApplicationPlan,
  setAppPlan: ApplicationPlan => void,
  isDisabled?: boolean,
  createApplicationPlanPath: string
}

const DEFAULT_APP_PLAN: ApplicationPlan = { disabled: true, id: -1, name: 'Select an Application Plan', issuer_id: -1 }

const ApplicationPlanSelect = ({ appPlans, isDisabled, appPlan, setAppPlan, createApplicationPlanPath }: Props) => {
  const showHint = !isDisabled && appPlans.length === 0
  return (
    <>
      <FormSelect
        isDisabled={isDisabled || appPlans.length === 0}
        value={appPlan.id}
        onChange={(id) => setAppPlan(appPlans.find(p => p.id === Number(id)) || DEFAULT_APP_PLAN)}
        id="cinstance_plan_id"
        name="cinstance[plan_id]"
      >
        {[DEFAULT_APP_PLAN, ...appPlans].map(toFormSelectOption)}
      </FormSelect>
      {showHint && (
        <p className="hint">
          {"An Application needs to subscribe to a Product's Application plan, and no Application plans exist for the selected Product. "}
          <Button component="a" variant="link" href={createApplicationPlanPath} isInline>
            Create a new Application plan
          </Button>
        </p>
      )}
    </>
  )
}

export { ApplicationPlanSelect, DEFAULT_APP_PLAN }
