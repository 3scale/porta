import { FunctionComponent, useState } from 'react'
import {
  FormGroup,
  Select,
  SelectOption,
  SelectVariant
} from '@patternfly/react-core'

type Props = {
  httpMethod: string,
  httpMethods: Array<string>,
  setHttpMethod: (arg1: string) => void
};

const HttpMethodSelect: FunctionComponent<Props> = ({
  httpMethod,
  httpMethods,
  setHttpMethod
}) => {
  const [isExpanded, setIsExpanded] = useState(false)

  const handleOnSelect = (_e: any, value: any) => {
    setIsExpanded(false)
    setHttpMethod(value)
  }

  return (
    <FormGroup
      isRequired
      label="Verb"
      fieldId="proxy_rule_http_method"
    >
      <input type="hidden" name="proxy_rule[http_method]" value={httpMethod} id="proxy_rule_http_method" />
      <Select
        variant={SelectVariant.single}
        aria-label="Select a httpMethod"
        onToggle={setIsExpanded}
        onSelect={handleOnSelect}
        selections={httpMethod}
        isExpanded={isExpanded}
      >
        {httpMethods.map(v => <SelectOption key={v} value={v} />)}
      </Select>
    </FormGroup>
  )
}

export { HttpMethodSelect, Props }
