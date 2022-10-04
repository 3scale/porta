
import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  increment: number,
  setIncrement: (arg1: number) => void
}

const IncrementByInput = (
  {
    increment,
    setIncrement
  }: Props
): React.ReactElement => (
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
      onChange={() => setIncrement}
    />
  </FormGroup>
)

export { IncrementByInput, Props }
