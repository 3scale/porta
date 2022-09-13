import * as React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  error?: string,
  path: string,
  setPath: (arg1: string) => void
};

const PathInput = (
  {
    error,
    path,
    setPath
  }: Props
): React.ReactElement => <FormGroup
  label="Path"
  validated="default"
  fieldId="backend_api_config_path"
  isValid={!error}
  helperTextInvalid={error}
>
  <TextInput
    type="text"
    id="backend_api_config_path"
    name="backend_api_config[path]"
    value={path}
    onChange={setPath}
    placeholder="/"
    isValid={!error}
  />
</FormGroup>

export { PathInput }
