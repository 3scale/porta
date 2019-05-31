// @flow

import React, { useState, useEffect } from 'react'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { ApplicationPlan, UserDefinedField } from 'Applications/types'

import './applicationForm.scss'

type Props = {
  plans: ApplicationPlan[],
  defaultPlan: ApplicationPlan,
  userDefinedFields: UserDefinedField[],
  servicePlansAllowed: boolean,
  setSubmitButtonDisabled: (?boolean) => void
}

const ApplicationForm = ({
  plans,
  defaultPlan,
  userDefinedFields,
  servicePlansAllowed,
  setSubmitButtonDisabled
}: Props) => {
  const [selectedPlan, setApplicationPlan] = useState(defaultPlan)
  const [term, setTerm] = useState(selectedPlan.name)

  useEffect(() => {
    const { servicePlans } = selectedPlan
    setSubmitButtonDisabled(servicePlans && servicePlans.length === 0)
  }, [selectedPlan])

  function onFocus () {
    setTerm('')
  }

  function onChange (ev: SyntheticEvent<HTMLInputElement>) {
    setTerm(ev.currentTarget.value)
  }

  function selectPlanByName () {
    const newPlan = plans.find(p => p.name === term)

    if (newPlan) {
      return setApplicationPlan(newPlan)
    }

    setTerm(selectedPlan.name)
  }

  function onKeyDown (ev: SyntheticKeyboardEvent<HTMLInputElement>) {
    if (ev.key === 'Enter') {
      selectPlanByName()
    }
  }

  const { contractedServicePlan, servicePlans } = selectedPlan
  const noServicePlans = servicePlans && servicePlans.length === 0
  const disabled = contractedServicePlan || noServicePlans

  function Options () {
    if (contractedServicePlan) {
      return <option>{contractedServicePlan.name}</option>
    }

    if (servicePlans) {
      return servicePlans.map(({ id, name }) => <option key={id} value={id}>{name}</option>)
    }

    return <option>No service plan for the application plan</option>
  }

  return (
    <ol>
      <li id="cinstance_plan_input" className="plan_selector required">
        <label htmlFor="cinstance_plan_id">Application plan<abbr title="required">*</abbr></label>
        <input type="hidden" name="cinstance[plan_id]" value={selectedPlan.id} />
        <div className='datalist-wrapper'>
          <i className='fa fa-sort-desc' />
          <input
            id="cinstance_plan_id"
            type="text"
            list="plans"
            value={term}
            onFocus={onFocus}
            onChange={onChange}
            onBlur={selectPlanByName}
            onKeyDown={onKeyDown}
            placeholder='Find an Application plan...'
          />
        </div>
        <datalist id="plans">
          {plans.map(({ id, name }) => <option key={id}>{name}</option>)}
        </datalist>
      </li>

      {servicePlansAllowed &&
        <li id="cinstance_service_plan_id_input" className="select optional">
          <label htmlFor="cinstance_service_plan_id">Service plan</label>
          <select id="cinstance_service_plan_id" name="cinstance[service_plan_id]" disabled={disabled}>
            <Options />
          </select>
          {noServicePlans &&
            <p className="inline-hints">
              <a id="link-help-new-application-service" href="/apiconfig/services">Create a service plan</a>
            </p>
          }
        </li>
      }

      {userDefinedFields.map(({ name, label, required, hidden }) => {
        return hidden || (
          <li
            key={name}
            id={`cinstance_${name}_input`}
            className={`string ${required ? 'required' : ''}`}
          >
            <label htmlFor={`cinstance_${name}`}>{label}
              {required && <abbr title="required">*</abbr>}
            </label>
            <input
              maxLength="255"
              id={`cinstance_${name}`}
              type="text"
              name={`cinstance[${name}]`}
            />
          </li>
        )
      })}
    </ol>
  )
}

const ApplicationFormWrapper = (props: Props, containerId: string) => createReactWrapper(<ApplicationForm {...props} />, containerId)

export { ApplicationForm, ApplicationFormWrapper }
