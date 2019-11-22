// @flow

import * as React from 'react'
import { FormFieldset, FormLegend } from 'Form'
import type { FieldGroupProps } from 'Settings/types'

type Props = {
  collection: FieldGroupProps[],
  ItemComponent: (FieldGroupProps) => React.Element<empty>,
  legend: string
}

const FormCollection = ({collection, ItemComponent, legend}: Props) => {
  return (
    <FormFieldset id={`fieldset-${legend.replace(/\s+/g, '')}`}>
      <FormLegend>{legend}</FormLegend>
      { collection.map(itemProps => <ItemComponent {...itemProps} key={itemProps.name} />) }
    </FormFieldset>
  )
}

export {
  FormCollection
}
