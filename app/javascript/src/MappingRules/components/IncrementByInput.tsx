import * as React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  increment: number,
  setIncrement: (arg1: number) => void
};

const IncrementByInput = (
  {
    increment,
    setIncrement
  }: Props
): React.ReactElement => <FormGroup
  isRequired
  label="Increment by"
  validated="default"
  fieldId="proxy_rule_delta"
  className="pf-c-form__group-narrow"
>
  <TextInput
    type="number"
    id="proxy_rule_delta"
    name="proxy_rule[delta]"
    value={increment}
    onChange={() => setIncrement}
  />
</FormGroup>

export { IncrementByInput, Props }
