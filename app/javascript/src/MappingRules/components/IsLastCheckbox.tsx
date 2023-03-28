import { Checkbox, FormGroup } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  isLast: boolean;
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

export type { Props }
export { IsLastCheckbox }
