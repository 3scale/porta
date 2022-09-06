// @flow

import * as React from 'react'
import { FormFieldset, FormLegend } from 'Settings/components/Common'
import type { FieldGroupProps } from 'Settings/types'

type Props = {
  collection: FieldGroupProps[],
  ItemComponent: (FieldGroupProps) => React.Node,
  legend: string
}

const FormCollection = ({ collection, ItemComponent, legend }: Props): React.Node => {
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
