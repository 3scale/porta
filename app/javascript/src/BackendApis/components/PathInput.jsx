// @flow

import * as React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  path: string,
  setPath: string => void
}

const PathInput = ({ path, setPath }: Props): React.Node => (
  <FormGroup
    isRequired
    label="Path"
    validated="default"
    fieldId="backend_api_config_path"
  >
    <TextInput
      type="text"
      id="backend_api_config_path"
      name="backend_api_config[path]"
      value={path}
      onChange={setPath}
    />
  </FormGroup>
)

export { PathInput }
