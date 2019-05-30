// @flow

import React, { useState, useEffect } from 'react'
import { createReactWrapper } from 'utilities/createReactWrapper'

import './applicationForm.scss'

type ApplicationPlan = {
  id: number,
  name: string,
}

type ServicePlan = {
  id: number,
  name: string,
  default: boolean
}

type UserDefinedField = {
  name: string,
  label: string,
  hidden: boolean,
  required: boolean
}

type Props = {
  plans: ApplicationPlan[],
  servicesContracted: number[],
  relationServiceAndServicePlans: { [number]: ServicePlan[] },
  relationPlansServices: { [number]: number },
  servicePlanContractedForService: { [number]: ServicePlan },
  setSubmitButtonDisabled: (boolean) => void,
  userDefinedFields: UserDefinedField[],
  servicePlansAllowed: boolean
}

const ApplicationForm = ({
  userDefinedFields,
  plans, servicesContracted, relationServiceAndServicePlans, setSubmitButtonDisabled,
  relationPlansServices, servicePlanContractedForService, servicePlansAllowed
}: Props) => {
  const [selectedPlan, setSelectedPlan] = useState(plans[0])
  const [term, setTerm] = useState(selectedPlan.name)
  const [servicePlans, setServicePlans] = useState([])
  const [servicePlansDisabled, setServicePlansDisabled] = useState(false)

  function checkSelectedPlan () {
    const serviceId = getServiceIdOfPlanId(selectedPlan.id)

    if (servicesContracted.indexOf(serviceId) > -1) {
      const contractedPlan = getContractedServicePlanForService(serviceId)
      setServicePlans([contractedPlan])

      setSubmitButtonDisabled(false)
      setServicePlansDisabled(true)
      return
    }

    const servicePlans = getServicePlansForService(serviceId)
    setServicePlans(servicePlans)

    if (servicePlans.length > 0) {
      setSubmitButtonDisabled(false)
      setServicePlansDisabled(false)
    } else {
      setSubmitButtonDisabled(true)
      setServicePlansDisabled(true)
    }
  }

  function getServiceIdOfPlanId (id: number): number {
    return relationPlansServices[id]
  }

  function getServicePlansForService (serviceId: number): ServicePlan[] {
    return relationServiceAndServicePlans[serviceId]
  }

  function getContractedServicePlanForService (serviceId: number): ServicePlan {
    return servicePlanContractedForService[serviceId]
  }

  function onFocus () {
    setTerm('')
  }

  function onChange (ev: SyntheticEvent<HTMLInputElement>) {
    setTerm(ev.currentTarget.value)
  }

  function selectPlanByName () {
    const plan = plans.find(p => p.name === term)

    if (plan) {
      return setSelectedPlan(plan)
    }

    setTerm(selectedPlan.name)
  }

  function onKeyDown (ev: SyntheticKeyboardEvent<HTMLInputElement>) {
    if (ev.key === 'Enter') {
      selectPlanByName()
    }
  }

  useEffect(checkSelectedPlan, [selectedPlan])

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
          <select id="cinstance_service_plan_id" name="cinstance[service_plan_id]" disabled={servicePlansDisabled}>
            {servicePlans.length
              ? servicePlans.map(({ id, name }) => <option key={id} value={id}>{name}</option>)
              : <option>No service plan for the application plan</option>
            }
          </select>
          {servicePlans.length === 0 &&
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
