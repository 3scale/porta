import { Checkbox, FormGroup } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

type Props = {
  isLast: boolean,
  setIsLast: (arg1: boolean) => void
}

const IsLastCheckbox: FunctionComponent<Props> = ({ isLast }) => (
  <FormGroup
    isRequired
    fieldId="proxy_rule_last"
    validated="default"
  >
    <Checkbox
      aria-label="Is Last"
      id="proxy_rule_last"
      isChecked={isLast}
      label="Last?"
      name="proxy_rule[last]"
    />
  </FormGroup>
)

export { IsLastCheckbox, Props }
