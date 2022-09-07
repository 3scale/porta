import * as React from 'react';

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  systemName: string,
  setSystemName: (arg1: string) => void
};

const SystemNameInput = (
  {
    systemName,
    setSystemName,
  }: Props,
): React.ReactElement => <FormGroup
  label="SystemName"
  validated="default"
  fieldId="backend_api_system_name"
  helperText="Only ASCII letters, numbers, dashes, and underscores are allowed."
>
  <TextInput
    type="text"
    id="backend_api_system_name"
    name="backend_api[system_name]"
    value={systemName}
    onChange={setSystemName}
  />
</FormGroup>

export { SystemNameInput }
