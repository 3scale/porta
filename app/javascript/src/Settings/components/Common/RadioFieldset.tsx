import { useState } from 'react'
import { Radio } from '@patternfly/react-core'
import { FormFieldset } from 'Settings/components/Common/FormFieldset'
import { FormLegend } from 'Settings/components/Common/FormLegend'

import type { SyntheticEvent, FunctionComponent } from 'react'
import type { FieldGroupProps, FieldCatalogProps } from 'Settings/types'

type CheckEvent = SyntheticEvent<HTMLButtonElement>

type Props = FieldCatalogProps & FieldGroupProps

const useSelectedOnChange = (value: unknown, onChange: unknown) => (
  typeof onChange === 'function'
    ? [value, onChange]
    // eslint-disable-next-line react/hook-use-state, @typescript-eslint/no-unsafe-return -- FIXME FIXME FIXME
    : useState(value).map(x => typeof x === 'function' ? (_c: unknown, e: CheckEvent) => x(e.currentTarget.value) : x)
)

const RadioFieldset: FunctionComponent<Props> = ({
  children,
  legend,
  name,
  value,
  catalog,
  onChange,
  ...props
}) => {
  const [selectedOnChange, setSelectedOnChange] = useSelectedOnChange(value, onChange)
  return (
    // eslint-disable-next-line react/jsx-props-no-spreading -- FIXME: remove this spreading
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
          onChange={setSelectedOnChange as (checked: boolean, event: React.FormEvent<HTMLInputElement>) => void}
        />
      ))}
      {children}
    </FormFieldset>
  )
}

export { RadioFieldset, Props }
