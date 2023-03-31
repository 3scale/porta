/* eslint-disable react/jsx-props-no-spreading -- FIXME: remove this spreading */
import { FormFieldset } from 'Settings/components/Common/FormFieldset'
import { FormLegend } from 'Settings/components/Common/FormLegend'
import { SelectGroup } from 'Settings/components/Common/SelectGroup'
import { TextInputGroup } from 'Settings/components/Common/TextInputGroup'

import type { FieldCatalogProps, FieldGroupProps } from 'Settings/types'

interface Props {
  type: FieldCatalogProps & FieldGroupProps;
  item: FieldGroupProps;
  legend: string;
}

const TypeItemCombo: React.FunctionComponent<Props> = ({
  type,
  item,
  legend
}) => (
  <FormFieldset id={`fieldset-${legend.replace(/\s+/g, '')}`}>
    <FormLegend>{legend}</FormLegend>
    <SelectGroup {...type} />
    <TextInputGroup {...item} />
  </FormFieldset>
)

export type { Props }
export { TypeItemCombo }
