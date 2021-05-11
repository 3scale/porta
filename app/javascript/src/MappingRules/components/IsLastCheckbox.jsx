// @flow

import * as React from 'react'

import { FormGroup, Checkbox } from '@patternfly/react-core'

type Props = {
  isLast: boolean,
  setIsLast: boolean => void
}

const IsLastCheckbox = ({ isLast, setIsLast }: Props): React.Node => (
  <FormGroup
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
)

export { IsLastCheckbox }
