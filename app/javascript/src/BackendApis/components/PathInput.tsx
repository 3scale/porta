import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  error?: string;
  path: string;
  setPath: (path: string) => void;
}

const PathInput: FunctionComponent<Props> = ({ error, path, setPath }) => {
  const validated = error ? 'error' : 'default'
  return (
    <FormGroup
      fieldId="backend_api_config_path"
      helperTextInvalid={error}
      label="Public Path"
      validated={validated}
    >
      <TextInput
        id="backend_api_config_path"
        name="backend_api_config[path]"
        placeholder="/"
        type="text"
        validated={validated}
        value={path}
        onChange={setPath}
      />
    </FormGroup>
  )
}

export type { Props }
export { PathInput }
