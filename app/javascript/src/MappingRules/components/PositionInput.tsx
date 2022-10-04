
import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  position: number,
  setPosition: (arg1: number) => void
}

const PositionInput = (
  {
    position,
    setPosition
  }: Props
): React.ReactElement => (
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
      onChange={() => setPosition}
    />
  </FormGroup>
)

export { PositionInput, Props }
