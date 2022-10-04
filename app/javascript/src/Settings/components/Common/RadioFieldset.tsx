/* eslint-disable react/jsx-props-no-spreading */
import { useState } from 'react'
import { Radio } from '@patternfly/react-core'
import { FormFieldset } from 'Settings/components/Common/FormFieldset'
import { FormLegend } from 'Settings/components/Common/FormLegend'

import type { FieldCatalogProps, FieldGroupProps } from 'Settings/types'

type CheckEvent = React.SyntheticEvent<HTMLButtonElement>

type Props = FieldGroupProps & FieldCatalogProps

// FIXME: WTF is this? Refactor and make it properly
const useSelectedOnChange = (value: string, onChange: undefined | ((value: string, event: React.SyntheticEvent<HTMLButtonElement>) => void)) => (
  typeof onChange === 'function'
    ? [value, onChange]
    // eslint-disable-next-line react/hook-use-state
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
          id={`service_method_${name}_${key}`}
          isChecked={selectedOnChange === key}
          label={catalog[key]}
          name={`service[${name}]`}
          value={key}
          onChange={setSelectedOnChange}
        />
      ))}
      {children}
    </FormFieldset>
  )
}

export { RadioFieldset, Props }
