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
  applicationPlans: AppPlan[],
  servicePlansAllowed: boolean
}

const ApplicationForm = ({ applicationPlans, servicePlansAllowed }: Props) => {
  const defApplicationPlan = (applicationPlans && applicationPlans.length && applicationPlans[0]) || undefined
  const defServicePlan = (defApplicationPlan && defApplicationPlan.servicePlans && applicationPlans[0].servicePlans[0]) || undefined

  const [plan, setPlan] = useState(defApplicationPlan)
  const [servicePlan, setServicePlan] = useState(defServicePlan)

  const servicePlans = plan ? plan.servicePlans : []
  const disabled = servicePlans.length === 0
  const placeholder = disabled ? 'No service plan for the application plan' : undefined

  return (
    <React.Fragment>
      <CustomSelect
        selected={plan}
        options={applicationPlans}
        onChange={setPlan}
        inputId='cinstance_plan_input'
        formId='cinstance_plan_id'
        formName='cinstance[plan_id]'
      />
      {servicePlansAllowed &&
        <CustomSelect
          selected={servicePlan}
          options={servicePlans}
          onChange={setServicePlan}
          inputId='cinstance_service_plan_id_input'
          formId='cinstance_service_plan_id'
          formName='cinstance[service_plan_id]'
          placeholder={placeholder}
          disabled={servicePlans.length === 0}
        />
      }
    </React.Fragment>
  )
}

type CustomSelectProps<T> = {
  selected?: T,
  options: $ReadOnlyArray<T>,
  onChange: T => void,
  inputId: string,
  formId: string,
  formName: string,
  disabled?: boolean,
  placeholder?: string
}

const CustomSelect = <T: {id: string, name: string}>({
  selected = {},
  options,
  onChange,
  inputId,
  formId,
  formName,
  disabled,
  placeholder
}: CustomSelectProps<T>
) => (
    <li id={inputId} className='select required'>
      <label htmlFor={formId}>Application plan</label>
      <select id={formId} name={formName} className='hidden'>
        {options.map(({ id, name }) => <option value={id} selected={selected.id === id}>{name}</option>)}
      </select>
      <SearchableSelect options={options} onOptionSelected={onChange} formName={formName} placeholder={placeholder} />
    </li>
  )

export { ApplicationForm }
