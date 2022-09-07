import * as React from 'react';

import { FormFieldset, FormLegend, TextInputGroup, SelectGroup } from 'Settings/components/Common'
import type { FieldGroupProps, FieldCatalogProps } from 'Settings/types'

type Props = {
  type: FieldCatalogProps & FieldGroupProps,
  item: FieldGroupProps,
  legend: string
};

const TypeItemCombo = (
  {
    type,
    item,
    legend,
  }: Props,
): React.ReactElement => {
  return (
    <FormFieldset id={`fieldset-${legend.replace(/\s+/g, '')}`}>
      <FormLegend>{legend}</FormLegend>
      <SelectGroup {...type} />
      <TextInputGroup {...item} />
    </FormFieldset>
  );
}

export {
  TypeItemCombo
}
