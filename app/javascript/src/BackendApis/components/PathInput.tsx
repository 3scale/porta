import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

type Props = {
  error?: string,
  path: string,
  setPath: (path: string) => void
}

const PathInput: FunctionComponent<Props> = ({ error, path, setPath }) => (
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
