import { FormGroup, Checkbox } from '@patternfly/react-core'
import { FunctionComponent } from 'react'

type Props = {
  isLast: boolean,
  setIsLast: (arg1: boolean) => void
};

const IsLastCheckbox: FunctionComponent<Props> = ({ isLast }) => <FormGroup
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

export { IsLastCheckbox, Props }
