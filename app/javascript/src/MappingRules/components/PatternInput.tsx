import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'
import type { FormGroupProps, TextInputProps } from '@patternfly/react-core'

interface Props {
  pattern: TextInputProps['pattern'];
  validatePattern: (pattern: string) => void;
  validated: FormGroupProps['validated'];
  helperTextInvalid: FormGroupProps['helperTextInvalid'];
}

const PatternInput: FunctionComponent<Props> = ({
  pattern,
  validatePattern,
  validated = 'default',
  helperTextInvalid = ''
}) => (
  <FormGroup
    isRequired
    fieldId="proxy_rule_pattern"
    helperText={(
      <>Examples: <code>{'/my-path/{someid}, /collection/{id}?filter={value}'}</code></>
    )}
    helperTextInvalid={helperTextInvalid}
    label="Pattern"
    validated={validated}
  >
    <TextInput
      id="proxy_rule_pattern"
      name="proxy_rule[pattern]"
      type="text"
      value={pattern}
      onChange={validatePattern}
    />
  </FormGroup>
)

export type { Props }
export { PatternInput }
