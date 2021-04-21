// @flow

import * as React from 'react'

import {
  FormGroup,
  Select,
  SelectOption,
  SelectVariant
} from '@patternfly/react-core'

type Props = {
  httpMethod: string,
  httpMethods: Array<string>,
  setHttpMethod: (string) => void
}

const HttpMethodSelect = ({ httpMethod, httpMethods, setHttpMethod }: Props): React.Node => {
  const [isExpanded, setIsExpanded] = React.useState(false)

  const handleOnSelect = (_e, value) => {
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

export { HttpMethodSelect }
