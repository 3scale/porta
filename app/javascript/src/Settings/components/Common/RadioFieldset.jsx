// @flow

import * as React from 'react'
import { useState } from 'react'
import { FormFieldset, FormLegend } from 'Form'
import { Radio } from '@patternfly/react-core'
import type { FieldGroupProps, FieldCatalogProps } from 'Settings/types'

type CheckEvent = SyntheticEvent<HTMLButtonElement>

type Props = FieldGroupProps & FieldCatalogProps

const useSelectedOnChange = (value, onChange) => (
  typeof onChange === 'function'
    ? [value, onChange]
    : useState(value).map(x => typeof x === 'function' ? (_c, e: CheckEvent) => x(e.currentTarget.value) : x)
)

const RadioFieldset = ({
  children,
  legend,
  name,
  value,
  catalog,
  onChange,
  ...props
}: Props) => {
  const [selectedOnChange, setSelectedOnChange] = useSelectedOnChange(value, onChange)
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

export {
  RadioFieldset
}
