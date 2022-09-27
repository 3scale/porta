import * as React from 'react'
import { useState } from 'react'

import { FormFieldset, FormLegend } from 'Settings/components/Common'
import { Radio } from '@patternfly/react-core'
import { FieldGroupProps, FieldCatalogProps } from 'Settings/types'

type CheckEvent = React.SyntheticEvent<HTMLButtonElement>;

type Props = FieldGroupProps & FieldCatalogProps;

// FIXME: WTF is this? Refactor and make it properly
const useSelectedOnChange = (value: string, onChange: undefined | ((value: string, event: React.SyntheticEvent<HTMLButtonElement>) => void)) => (
  typeof onChange === 'function'
    ? [value, onChange]
    : useState(value).map(x => typeof x === 'function' ? (_c: any, e: CheckEvent) => x(e.currentTarget.value) : x) as any
)

const RadioFieldset: React.FunctionComponent<Props> = ({
  children,
  legend,
  name,
  value,
  catalog,
  onChange,
  ...props
}) => {
  const [selectedOnChange, setSelectedOnChange] = useSelectedOnChange(value as string, onChange)
  return (
    <FormFieldset id={`fieldset-${name}`} {...props} >
      <FormLegend>{legend}</FormLegend>
      {Object.keys(catalog).map(key => (
        <Radio
          key={key}
          value={key}
          isChecked={selectedOnChange === key}
          name={`service[${name}]`}
          onChange={setSelectedOnChange}
          label={catalog[key]}
          id={`service_method_${name}_${key}`}
        />
      ))}
      {children}
    </FormFieldset>
  )
}

export { RadioFieldset, Props }
