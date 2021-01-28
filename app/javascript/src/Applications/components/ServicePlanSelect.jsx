// @flow

import React from 'react'

import {
  FormGroup,
  FormSelect
} from '@patternfly/react-core'
import { toFormSelectOption } from 'utilities/patternfly-utils'

import type { ServicePlan } from 'Applications/types'

type Props = {
  isDisabled?: boolean,
  isRequired?: boolean,
  servicePlans: ServicePlan[],
  servicePlan: ServicePlan,
  setServicePlan: ServicePlan => void
}

const SERVICE_PLAN_PLACEHOLDER: ServicePlan = { disabled: true, id: -1, name: 'Select a Service Plan', issuer_id: -1, default: false }

const ServicePlanSelect = ({ isDisabled, isRequired, servicePlans, servicePlan, setServicePlan }: Props) => (
  <FormGroup
    label="Service plan"
    isRequired={isRequired}
    validated="default"
    fieldId="cinstance_service_plan_id"
  >
    <FormSelect
      isDisabled={isDisabled}
      value={servicePlan.id}
      onChange={(id) => setServicePlan(servicePlans.find(p => p.id === Number(id)) || SERVICE_PLAN_PLACEHOLDER)}
      id="cinstance_service_plan_id"
      name="cinstance[service_plan_id]"
    >
      {/* $FlowFixMe */}
      {[SERVICE_PLAN_PLACEHOLDER, ...servicePlans].map(toFormSelectOption)}
    </FormSelect>
  </FormGroup>
)

export { ServicePlanSelect, SERVICE_PLAN_PLACEHOLDER }
