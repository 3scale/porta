import { useState } from 'react'
import {
  FormGroup,
  Select,
  SelectOption,
  SelectVariant
} from '@patternfly/react-core'

import type { SelectOptionObject } from '@patternfly/react-core'
import type { FunctionComponent } from 'react'

interface Props {
  httpMethod: string;
  httpMethods: string[];
  setHttpMethod: (httpMethod: string) => void;
}

const HttpMethodSelect: FunctionComponent<Props> = ({
  httpMethod,
  httpMethods,
  setHttpMethod
}) => {
  const [isExpanded, setIsExpanded] = useState(false)

  const handleOnSelect = (_e: unknown, value: SelectOptionObject | string) => {
    setIsExpanded(false)
    setHttpMethod(value as string)
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

export type { Props }
export { HttpMethodSelect }
