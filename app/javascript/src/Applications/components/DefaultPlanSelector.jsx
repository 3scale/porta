// @flow

import React, { useState, useEffect } from 'react'

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

type Props = {
  currentPlanId: number,
  plans: Array<{
    id: number,
    name: string
  }>
}

const DefaultPlanSelector = ({ currentPlanId, plans }: Props) => {
  const [selection, setSelection] = useState(() => {
    if (currentPlanId) {
      const plan = plans.find(p => p.id === currentPlanId)
      return plan ? new PlanSelectOptionObject(plan) : undefined
    }
  })
  const [isExpanded, setIsExpanded] = useState(false)
  const [isLoading, setIsLoading] = useState(false)

  const onSelect = (_e, option: PlanSelectOptionObject) => {
    setSelection(option)
    setIsExpanded(false)
  }

  const onClear = () => {
    setSelection(undefined)
    // TODO: focus input
  }

  useEffect(() => {
    console.log(selection)
    // TODO: When plan changes, send a post request
    console.log(setIsLoading)
  }, [selection])

  const options = [{ id: -1, name: '(Select none)' }, ...plans].map(p => new PlanSelectOptionObject(p))

  return (
    <PageSection variant={PageSectionVariants.light} className="pf-u-mb-md">
      <Form>
        <FormGroup
          label="Default plan"
          validated="default"
          fieldId="cinstance_plan_id"
          helperText="Default application plan (if any) is selected automatically upon service subscription."
        >
          <Select
            variant={SelectVariant.typeahead}
            aria-label="Select application plan"
            placeholderText="Select application plan"
            onToggle={() => setIsExpanded(!isExpanded)}
            onSelect={onSelect}
            onClear={onClear}
            isExpanded={isExpanded}
            isDisabled={isLoading}
            selections={selection}
          >
            {options.map(p => <SelectOption key={p.id} value={p} />)}
          </Select>
        </FormGroup>
      </Form>
    </PageSection>
  )
}

export { DefaultPlanSelector }
