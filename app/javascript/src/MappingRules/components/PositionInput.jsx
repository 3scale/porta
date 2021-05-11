// @flow

import * as React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  position: number,
  setPosition: number => void
}

const PositionInput = ({ position, setPosition }: Props): React.Node => (
  <FormGroup
    isRequired
    label="Position"
    validated="default"
    fieldId="proxy_rule_position"
    className="pf-c-form__group-narrow"
  >
    <TextInput
      type="number"
      id="proxy_rule_position"
      name="proxy_rule[position]"
      value={position}
      onChange={setPosition}
    />
  </FormGroup>
)

export { PositionInput }
