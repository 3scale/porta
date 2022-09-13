import * as React from 'react'

import { FormGroup, Checkbox } from '@patternfly/react-core'

type Props = {
  isLast: boolean,
  setIsLast: (arg1: boolean) => void
};

const IsLastCheckbox = (
  {
    isLast,
    setIsLast
  }: Props
): React.ReactElement => <FormGroup
  isRequired
  validated="default"
  fieldId="proxy_rule_last"
>
  <Checkbox
    isChecked={isLast}
    label="Last?"
    id="proxy_rule_last"
    name="proxy_rule[last]"
    aria-label="Is Last"
  />
</FormGroup>

export { IsLastCheckbox }
