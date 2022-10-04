import { useState } from 'react'
import {
  FormGroup,
  Select,
  SelectOption,
  SelectVariant
} from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

type Props = {
  httpMethod: string,
  httpMethods: Array<string>,
  setHttpMethod: (arg1: string) => void
}

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
      fieldId="proxy_rule_http_method"
      label="Verb"
    >
      <input id="proxy_rule_http_method" name="proxy_rule[http_method]" type="hidden" value={httpMethod} />
      <Select
        aria-label="Select a httpMethod"
        isExpanded={isExpanded}
        selections={httpMethod}
        variant={SelectVariant.single}
        onSelect={handleOnSelect}
        onToggle={setIsExpanded}
      >
        {httpMethods.map(v => <SelectOption key={v} value={v} />)}
      </Select>
    </FormGroup>
  )
}

export { HttpMethodSelect, Props }
