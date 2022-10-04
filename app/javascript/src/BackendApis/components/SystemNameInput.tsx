
import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  systemName: string,
  setSystemName: (arg1: string) => void
}

const SystemNameInput = (
  {
    systemName,
    setSystemName
  }: Props
): React.ReactElement => (
  <FormGroup
    fieldId="backend_api_system_name"
    helperText="Only ASCII letters, numbers, dashes, and underscores are allowed."
    label="SystemName"
    validated="default"
  >
    <TextInput
      id="backend_api_system_name"
      name="backend_api[system_name]"
      type="text"
      value={systemName}
      onChange={setSystemName}
    />
  </FormGroup>
)

export { SystemNameInput, Props }
