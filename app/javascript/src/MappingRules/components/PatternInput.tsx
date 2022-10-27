
import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  pattern: string,
  validatePattern: (arg1: string) => void,
  validated: 'default' | 'success' | 'error' | undefined,
  helperTextInvalid: string
};

const PatternInput = (
  {
    pattern,
    validatePattern,
    validated = 'default',
    helperTextInvalid = ''
  }: Props
): React.ReactElement => {
  return (
    <FormGroup
      isRequired
      label="Pattern"
      validated={validated}
      fieldId="proxy_rule_pattern"
      helperText={(
        <>Examples: <span className="pf-m-redhatmono-font">{'/my-path/{someid}, /collection/{id}?filter={value}'}</span></>
      )}
      helperTextInvalid={helperTextInvalid}
    >
      <TextInput
        type="text"
        id="proxy_rule_pattern"
        name="proxy_rule[pattern]"
        value={pattern}
        onChange={validatePattern}
      />
    </FormGroup>
  )
}

export { PatternInput, Props }
