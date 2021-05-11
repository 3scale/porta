// @flow

import * as React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  pattern: string,
  setPattern: string => void
}

const PatternInput = ({ pattern, setPattern }: Props): React.Node => (
  <FormGroup
    isRequired
    label="Pattern"
    validated="default"
    fieldId="proxy_rule_pattern"
    helperText="Examples: /my-path/{some-id}, /collection/{id}?filter={value}"
  >
    <TextInput
      type="text"
      id="proxy_rule_pattern"
      name="proxy_rule[pattern]"
      value={pattern}
      onChange={setPattern}
    />
  </FormGroup>
)

export { PatternInput }
