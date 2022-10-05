import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'
import type { TextInputProps } from '@patternfly/react-core'

type Props = {
  position: TextInputProps['value'],
  setPosition: (position: number) => void
}

const PositionInput: FunctionComponent<Props> = ({
  position,
  setPosition
}) => (
  <FormGroup
    isRequired
    className="pf-c-form__group-narrow"
    fieldId="proxy_rule_position"
    label="Position"
    validated="default"
  >
    <TextInput
      id="proxy_rule_position"
      name="proxy_rule[position]"
      type="number"
      value={position}
      onChange={(value) => setPosition(Number(value))}
    />
  </FormGroup>
)

export { PositionInput, Props }
