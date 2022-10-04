
import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  name: string,
  setName: (name: string) => void
}

const NameInput = (
  {
    name,
    setName
  }: Props
): React.ReactElement => (
  <FormGroup
    isRequired
    fieldId="backend_api_name"
    label="Name"
    validated="default"
  >
    <TextInput
      id="backend_api_name"
      name="backend_api[name]"
      type="text"
      value={name}
      onChange={(value) => setName(value)}
    />
  </FormGroup>
)

export { NameInput, Props }
