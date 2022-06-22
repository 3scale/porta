// @flow

import * as React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  pattern: string,
  validatePattern: string => void,
  validated: string,
  helperTextInvalid: string
}

const PatternInput = ({ pattern, validatePattern, validated = 'default', helperTextInvalid = '' }: Props): React.Node => {
  return (
    <FormGroup
      isRequired
      label="Pattern"
      validated={validated}
      fieldId="proxy_rule_pattern"
      helperText={(
        <>Examples: <span className="pf-m-redhatmono-font">{'/my-path/{someid}, /collection/{id}?filter={value}'}</span></>
      )}
      helperTextInvalid={helperTextInvalid}
    >
      <TextInput
        type="text"
        id="proxy_rule_pattern"
        name="proxy_rule[pattern]"
        value={pattern}
        onChange={validatePattern}
      />
    </FormGroup>
  )
}

export { PatternInput }
