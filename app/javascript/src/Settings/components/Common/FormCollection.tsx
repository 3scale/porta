
import { FormFieldset, FormLegend } from 'Settings/components/Common'
import { FieldGroupProps } from 'Settings/types'

type Props = {
  collection: FieldGroupProps[],
  ItemComponent: React.FunctionComponent<FieldGroupProps>,
  legend: string
};

const FormCollection: React.FunctionComponent<Props> = ({
  collection,
  ItemComponent,
  legend
}) => {
  return (
    <FormFieldset id={`fieldset-${legend.replace(/\s+/g, '')}`}>
      <FormLegend>{legend}</FormLegend>
      { collection.map(itemProps => <ItemComponent {...itemProps} key={itemProps.name} />) }
    </FormFieldset>
  )
}

export { FormCollection, Props }
