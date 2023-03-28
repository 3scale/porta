import { FormFieldset } from 'Settings/components/Common/FormFieldset'
import { FormLegend } from 'Settings/components/Common/FormLegend'

import type { FunctionComponent } from 'react'
import type { FieldGroupProps } from 'Settings/types'

interface Props {
  collection: FieldGroupProps[];
  // eslint-disable-next-line @typescript-eslint/naming-convention -- TODO: instead of passing a class and rendering here, pass the component already like <FormCollection item={<ItemComponent ... />} />
  ItemComponent: FunctionComponent<FieldGroupProps>;
  legend: string;
}

const FormCollection: FunctionComponent<Props> = ({
  collection,
  // eslint-disable-next-line @typescript-eslint/naming-convention -- TODO: instead of passing a class and rendering here, pass the component already like <FormCollection item={<ItemComponent ... />} />
  ItemComponent,
  legend
}) => (
  <FormFieldset id={`fieldset-${legend.replace(/\s+/g, '')}`}>
    <FormLegend>{legend}</FormLegend>
    {/* eslint-disable-next-line react/jsx-props-no-spreading */}
    {collection.map(itemProps => <ItemComponent {...itemProps} key={itemProps.name} />)}
  </FormFieldset>
)

export type { Props }
export { FormCollection }
