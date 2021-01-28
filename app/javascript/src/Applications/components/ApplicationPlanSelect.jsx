// @flow

import React from 'react'

import {
  FormGroup,
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

const APP_PLAN_PLACEHOLDER: ApplicationPlan = { disabled: true, id: -1, name: 'Select an Application Plan', issuer_id: -1 }

const ApplicationPlanSelect = ({ appPlans, isDisabled, appPlan, setAppPlan, createApplicationPlanPath }: Props) => {
  const showHint = !isDisabled && appPlans.length === 0
  return (
    <FormGroup
      label="Application plan"
      isRequired
      validated="default"
      fieldId="cinstance_plan_id"
    >
      <FormSelect
        isDisabled={isDisabled || appPlans.length === 0}
        value={appPlan.id}
        onChange={(id) => setAppPlan(appPlans.find(p => p.id === Number(id)) || APP_PLAN_PLACEHOLDER)}
        id="cinstance_plan_id"
        name="cinstance[plan_id]"
      >
        {/* $FlowFixMe */}
        {[APP_PLAN_PLACEHOLDER, ...appPlans].map(toFormSelectOption)}
      </FormSelect>
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

export { ApplicationPlanSelect, APP_PLAN_PLACEHOLDER }
