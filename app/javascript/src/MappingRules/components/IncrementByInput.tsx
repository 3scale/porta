import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  increment: number;
  setIncrement: (value: number) => void;
}

const IncrementByInput: FunctionComponent<Props> = ({
  increment,
  setIncrement
}) => (
  <FormGroup
    isRequired
    className="pf-c-form__group-narrow"
    fieldId="proxy_rule_delta"
    label="Increment by"
    validated="default"
  >
    <TextInput
      id="proxy_rule_delta"
      name="proxy_rule[delta]"
      type="number"
      value={increment}
      onChange={(value) => { setIncrement(Number(value)) }}
    />
  </FormGroup>
)

export { IncrementByInput, Props }
