// @flow

import React, { useState, useEffect } from 'react'
import * as ajax from 'utilities/ajax'

import {
  Form,
  FormGroup,
  PageSection,
  PageSectionVariants,
  Select,
  SelectOption,
  SelectVariant
} from '@patternfly/react-core'
import { PlanSelectOptionObject } from 'Applications'

import './DefaultPlanSelect.scss'

type Service = {
  id: number,
  name: string,
}

type ApplicationPlan = {
  id: number,
  name: string
}

type Props = {
  currentService: Service,
  currentPlan?: ApplicationPlan,
  plans: ApplicationPlan[]
}

const NO_DEFAULT_PLAN: ApplicationPlan = { id: -1, name: '(No default plan)' }

// TODO: prevent reload screen when pressing Enter

const DefaultPlanSelect = ({ currentService, currentPlan = NO_DEFAULT_PLAN, plans }: Props) => {
  const [selection, setSelection] = useState<PlanSelectOptionObject | null>(new PlanSelectOptionObject(currentPlan))
  const [isExpanded, setIsExpanded] = useState(false)
  const [isLoading, setIsLoading] = useState(false)

  const onSelect = (_e, newPlan: PlanSelectOptionObject) => {
    setSelection(newPlan)
    setIsExpanded(false)
    setIsLoading(true)

    const body = newPlan.id >= 0 ? new URLSearchParams({ id: newPlan.id.toString() }) : undefined

    // making request...
    ajax.post(`/apiconfig/services/${currentService.id}/application_plans/masterize`, body)
      .then(data => {
        console.log(data)
        if (data.ok) {
          $.flash('Default plan was updated')
        } else {
          $.flash.error('Plan could not be updated')
        }
      })
      .catch(err => {
        console.error(err)
        $.flash.error('An error ocurred. Please try again later.')
      })
      .finally(() => setIsLoading(false))
  }

  const onClear = () => {
    setSelection(null)
  }

  useEffect(() => {
    console.log(setIsLoading)
    // console.log('Setting new default: ' + String(selection))
    // setIsLoading(true)

    // setTimeout(() => {
    //   setIsLoading(false)
    // }, 500)
  }, [selection])

  const options = [NO_DEFAULT_PLAN, ...plans]
    .filter(p => p.id !== currentPlan.id) // Don't show the current default plan
    .map(p => new PlanSelectOptionObject(p))

  return (
    <PageSection variant={PageSectionVariants.light} className="pf-u-mb-md" id="default-plan-selector">
      <Form onSubmit={e => e.preventDefault()}>
        <FormGroup
          label="Default plan"
          fieldId="application_plan_id"
          helperText="Default application plan (if any) is selected automatically upon service subscription."
        >
          <Select
            variant={SelectVariant.typeahead}
            aria-label="Select application plan"
            placeholderText="Select application plan"
            onToggle={() => setIsExpanded(!isExpanded)}
            onSelect={onSelect}
            onClear={onClear}
            onKeyDown={e => {
              console.log('pressed')
              e.preventDefault()
            }}
            onBlur={() => console.log('blur')}
            isExpanded={isExpanded}
            isDisabled={isLoading}
            selections={selection}
            isCreatable={false}
          >
            {options.map(p => <SelectOption key={p.id} value={p} />)}
          </Select>
        </FormGroup>
      </Form>
    </PageSection>
  )
}

export { DefaultPlanSelect }
