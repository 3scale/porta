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

type Props = {
  plans: ApplicationPlan[],
  servicesContracted: number[],
  relationServiceAndServicePlans: {[number]: ServicePlan[]},
  relationPlansServices: {[number]: number},
  servicePlanContractedForService: {[number]: ServicePlan}
}

const ApplicationForm = ({ plans, servicesContracted, relationServiceAndServicePlans, relationPlansServices, servicePlanContractedForService }: Props) => {
  const [selectedPlan, setSelectedPlan] = useState(plans[0])
  const [term, setTerm] = useState(selectedPlan.name)

  function checkSelectedPlan () {
    const serviceId = getServiceIdOfPlanId(selectedPlan.id)
    const servicePlans = getServicePlansForService(serviceId)

    enableForm()

    if (servicesContracted.indexOf(serviceId) > -1) {
      const { id, name } = getContractedServicePlanForService(serviceId)
      $('#cinstance_service_plan_id').html(`<option value="${id}"> ${name} </option>`)
      $('#cinstance_service_plan_id').attr('disabled', 'disabled')
    } else if (servicePlans.length !== 0) {
      setServicePlansSelectOptions(servicePlans)
    } else {
      $('#cinstance_service_plan_id').html('<option> No service plan for the application plan </option>')
      disableForm()
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

  function enableForm () {
    $('#link-help-new-application-service').toggle(false)
    enableField('#submit-new-app')
    enableField('#cinstance_service_plan_id')
  }

  function disableForm () {
    $('#link-help-new-application-service').toggle(true)
    disableField('#submit-new-app')
    disableField('#cinstance_service_plan_id')
  }

  function enableField (field: string) {
    $(field).removeAttr('disabled')
  }

  function disableField (field: string) {
    $(field).attr('disabled', 'disabled')
  }

  function setServicePlansSelectOptions (servicePlans: ServicePlan[]) {
    let options = ''
    servicePlans.forEach((plan, index) => {
      const selected = plan.default ? 'selected="selected"' : ''
      options += `<option value="${plan.id}" ${selected}>${plan.name}</option>`
    })
    $('#cinstance_service_plan_id').html(options)
    $('#cinstance_service_plan_id').removeAttr('disabled')
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
    <React.Fragment>
      <label htmlFor="cinstance_plan_id">Application plan<abbr title="required">*</abbr></label>
      <input type="hidden" name="cinstance[plan_id]" value={selectedPlan.id} />
      <div className='datalist-wrapper'>
        <i className='fa fa-sort-desc' />
        <input
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
        {plans.map(({id, name}) => <option key={id} onClick={() => console.log('clicked', id)}>{name}</option>)}
      </datalist>
    </React.Fragment>
  )
}

const ApplicationFormWrapper = (props: Props, containerId: string) => createReactWrapper(<ApplicationForm {...props} />, containerId)

export { ApplicationForm, ApplicationFormWrapper }
