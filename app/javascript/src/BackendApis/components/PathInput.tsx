
import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  error?: string,
  path: string,
  setPath: (arg1: string) => void
}

const PathInput = (
  {
    error,
    path,
    setPath
  }: Props
): React.ReactElement => (
  <FormGroup
    fieldId="backend_api_config_path"
    helperTextInvalid={error}
    isValid={!error}
    label="Path"
    validated="default"
  >
    <TextInput
      id="backend_api_config_path"
      isValid={!error}
      name="backend_api_config[path]"
      placeholder="/"
      type="text"
      value={path}
      onChange={setPath}
    />
  </FormGroup>
)

export { PathInput, Props }
