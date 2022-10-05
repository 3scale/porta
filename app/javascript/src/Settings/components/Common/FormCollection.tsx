import { FormFieldset } from 'Settings/components/Common/FormFieldset'
import { FormLegend } from 'Settings/components/Common/FormLegend'

import type { FieldGroupProps } from 'Settings/types'

type Props = {
  collection: FieldGroupProps[],
  ItemComponent: React.FunctionComponent<FieldGroupProps>,
  legend: string
}

const FormCollection: React.FunctionComponent<Props> = ({
  collection,
  ItemComponent,
  legend
}) => (
  <FormFieldset id={`fieldset-${legend.replace(/\s+/g, '')}`}>
    <FormLegend>{legend}</FormLegend>
    {/* eslint-disable-next-line react/jsx-props-no-spreading */}
    { collection.map(itemProps => <ItemComponent {...itemProps} key={itemProps.name} />) }
  </FormFieldset>
)

export { FormCollection, Props }
