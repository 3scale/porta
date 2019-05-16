// @flow

import React from 'react'
import { createReactWrapper } from 'utilities/createReactWrapper'

type ApplicationPlan = {
  id: number,
  name: string
}

type Props = {
  plans: ApplicationPlan[],
  onChange: () => void
}

const ApplicationForm = ({ plans, onChange }: Props) => (
  <React.Fragment>
    <label htmlFor="cinstance_plan_id">Application plan<abbr title="required">*</abbr></label>
    <select
      name="cinstance[plan_id]"
      id="cinstance_plan_id"
      aria-hidden="true"
      onChange={onChange}
    >
      {plans.map(({id, name}) => <option key={id} value={id}>{name}</option>)}
    </select>
  </React.Fragment>
)

const ApplicationFormWrapper = (props: Props, containerId: string) => createReactWrapper(<ApplicationForm {...props} />, containerId)

export { ApplicationForm, ApplicationFormWrapper }
