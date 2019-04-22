// @flow

import React, { useState } from 'react'
import { SearchableSelect } from 'Applications/SearchableSelect'

type ServicePlan = {
  id: string,
  name: string
}

type AppPlan = {
  id: string,
  name: string,
  servicePlans: ServicePlan[]
}

type Props = {
  applicationPlans: AppPlan[]
}

const ApplicationForm = ({ applicationPlans }: Props) => {
  const [plan, setPlan] = useState(applicationPlans[0])
  const [servicePlan, setServicePlan] = useState(applicationPlans[0].servicePlans[0])
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')

  const onInputChange = (event: SyntheticEvent<HTMLInputElement>) => setName(event.currentTarget.value)
  const onDescriptionChange = (event: SyntheticEvent<HTMLInputElement>) => setDescription(event.currentTarget.value)

  return (
    <fieldset className='inputs'>
      <ol>
        <PlanSelect plan={plan} applicationPlans={applicationPlans} onChange={setPlan} />
        <ServicePlanSelect servicePlan={servicePlan} servicePlans={plan.servicePlans} onChange={setServicePlan}/>
        <NameInput name={name} onChange={onInputChange} />
        <DescriptionTextarea description={description} onChange={onDescriptionChange} />
      </ol>
    </fieldset>
  )
}

const PlanSelect = ({ plan, applicationPlans, onChange }: {
  plan: AppPlan,
  applicationPlans: Array<AppPlan>,
  onChange: AppPlan => void
}) => {
  const formId = 'cinstance_plan_id'
  return (
    <li id='cinstance_plan_input' className='select required'>
      <label htmlFor={formId}>Application plan</label>
      <input id={formId} name='cinstance[plan_id]' className='HiddenForm' value={plan.id} readOnly />
      <SearchableSelect options={applicationPlans} onOptionSelected={onChange} formName='cinstance[plan_id]' />
    </li>
  )
}

const ServicePlanSelect = ({ servicePlan, servicePlans, onChange }: {
  servicePlan: ServicePlan,
  servicePlans: Array<ServicePlan>,
  onChange: ServicePlan => void
}) => {
  const formId = 'cinstance_service_plan_id'
  return (
    <li id='cinstance_service_plan_id_input' className='select optional'>
      <label htmlFor={formId}>Service plan</label>
      <input id={formId} name='cinstance[service_plan_id]' className='HiddenForm' value={servicePlan.id} readOnly />
      <SearchableSelect options={servicePlans} onOptionSelected={onChange} formName='cinstance[service_plan_id]' />
    </li>
  )
}

const NameInput = ({ name, onChange }) => (
  <li id='cinstance_name_input' className='string required'>
    <label htmlFor="cinstance_name">Name</label>
    <input maxLength="255" id="cinstance_name" type="text" name="cinstance[name]" value={name} onChange={onChange} />
  </li>
)

const DescriptionTextarea = ({ description, onChange }) => (
  <li id='cinstance_description_input' className='text required'>
    <label htmlFor="cinstance_description">Description</label>
    <textarea rows="20" id="cinstance_description" name="cinstance[description]" value={description} onChange={onChange} />
  </li>
)

export { ApplicationForm }
