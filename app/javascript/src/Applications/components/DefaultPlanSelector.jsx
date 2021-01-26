// @flow

import React
  from 'react'

import {
  Form,
  FormGroup,
  PageSection,
  PageSectionVariants,
  Select,
  SelectOption,
  SelectVariant
} from '@patternfly/react-core'

import 'Applications/styles/applications.scss'

type Props = {}

// TODO: options will need to be sorted alphabetically
const options = [
  { value: '(Select none)', disabled: false, isPlaceholder: true },
  { value: 'Application plan A', disabled: false },
  { value: 'Application plan B', disabled: false },
  { value: 'Some other application plan A', disabled: false },
  { value: 'Yet another application plan', disabled: false }
]
const isExpanded = false
const isDisabled = false

// TODO: onToggle, onSelect, and onClear will need to be implemented

const DefaultPlanSelector = (props: Props) => {
  return (
    <>
      <PageSection variant={PageSectionVariants.light} className="pf-u-mb-md">
        <Form>
          <FormGroup
            label="Default plan"
            // isRequired
            validated="default"
            fieldId="cinstance_plan_id"
            helperText="Default application plan (if any) is selected automatically upon service subscription."
          >
            <Select
              variant={SelectVariant.typeahead}
              aria-label = "Select application plan"
              placeholderText="Select application plan"
              onToggle = {() => {}}
              onSelect = {() => {}}
              onClear = {() => {}}
              isExpanded = {isExpanded}
              isDisabled = {isDisabled}
            >
              {options.map((option, index) => (
                <SelectOption
                  isDisabled={option.disabled}
                  key={index}
                  value={option.value}
                  isPlaceholder={option.isPlaceholder}
                />
              ))}
            </Select>
          </FormGroup>
        </Form>
      </PageSection>
    </>
  )
}

export { DefaultPlanSelector }
