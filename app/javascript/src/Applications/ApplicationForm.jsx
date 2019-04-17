// @flow

import React, { useState } from 'react'
import { SearchableSelect } from 'Applications/SearchableSelect'

type AppPlan = {
  id: string,
  name: string,
  servicePlans: any[]
}

type Props = {
  applicationPlans: AppPlan[]
}

const ApplicationForm = ({ applicationPlans }: Props) => {
  const [plan, setPlan] = useState(applicationPlans[0])
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')

  const onAppPlanChange = (appPlan: AppPlan) => setPlan(appPlan)
  const onInputChange = (event: SyntheticEvent<HTMLInputElement>) => setName(event.currentTarget.value)
  const onDescriptionChange = (event: SyntheticEvent<HTMLInputElement>) => setDescription(event.currentTarget.value)

  return (
    <fieldset className='inputs'>
      <ol>
        <li id='cinstance_plan_input' className='select required'>
          <SearchableSelect options={applicationPlans} label='Application plan' formId='cinstance_plan_id' formName='cinstance[plan_id]' onOptionSelect={appPlan => onAppPlanChange(appPlan)} />
        </li>
        <li id='cinstance_service_plan_id_input' className='select optional'>
          <SearchableSelect options={plan.servicePlans} label='Service plan' formId='cinstance_service_plan_id' formName='cinstance[service_plan_id]' />
        </li>
        <li id='cinstance_name_input' className='string required'>
          <label htmlFor="cinstance_name">Name</label>
          <input maxLength="255" id="cinstance_name" type="text" name="cinstance[name]" value={name} onChange={e => onInputChange(e)} />
        </li>
        <li id='cinstance_description_input' className='text required'>
          <label htmlFor="cinstance_description">Description</label>
          <textarea rows="20" id="cinstance_description" name="cinstance[description]" value={description} onChange={e => onDescriptionChange(e)} />
        </li>
      </ol>
    </fieldset>
  )
}

export { ApplicationForm }
